import json, sys, pathlib
from neo4j import GraphDatabase

"""
Usage:
  python tools/load_core_ontology.py bolt://localhost:7687 neo4j password data/core-medical-ontology.json

Expected JSON structure (flexible; unknown sections are ignored):
{
  "diseases": [
    {"id":"dis:influenza","name":"Influenza","codeSystem":"SNOMEDCT","code":"6142004"}
  ],
  "syndromes": [...],
  "medications": [
    {"id":"med:ibuprofen","name":"Ibuprofen","codeSystem":"RxNorm","code":"5640"}
  ],
  "observations": [
    {"id":"obs-1","code":"LOINC:LP21258-6","value":"38.8","unit":"C","effTime":"2025-08-10T15:10:00Z"}
  ],
  "genes": [{"id":"gene:BRCA1","symbol":"BRCA1"}],
  "variants": [{"id":"var:BRCA1:p.V1736A","hgvs":"NM_007294.4:c.5207T>C","clinvarId":"XXXX"}],
  "relationships": [
     {"type":"INDICATED_FOR","from":"med:ibuprofen","to":"dis:influenza"},
     {"type":"ASSOCIATED_WITH","from":"var:BRCA1:p.V1736A","to":"dis:breast_cancer"},
     {"type":"IN_GENE","from":"var:BRCA1:p.V1736A","to":"gene:BRCA1"}
  ]
}
"""

def chunks(it, n=500):
    buf = []
    for x in it:
        buf.append(x)
        if len(buf) >= n:
            yield buf
            buf = []
    if buf:
        yield buf

def upsert_entities(tx, label, items, props):
    cy = f"""
    UNWIND $rows AS row
    MERGE (n:{label} {{id: row.id}})
    SET {", ".join([f"n.{p} = row.{p}" for p in props if p != "id"])}
    """
    tx.run(cy, rows=items)

def upsert_relationships(tx, rels):
    # Supports common rel types from our schema; ignores unknown types gracefully
    cy = """
    UNWIND $rows AS row
    WITH row
    MATCH (a {id: row.from}), (b {id: row.to})
    CALL {
      WITH row, a, b
      WITH row, a, b
      CALL {
        WITH row, a, b
        WITH row, a, b
        RETURN row.type AS t
      }
      WITH t, a, b
      CALL {
        WITH t, a, b
        WITH t, a, b
        // Create relationship based on type
        RETURN CASE t
          WHEN 'INDICATED_FOR'      THEN apoc.create.relationship(a, 'INDICATED_FOR', {}, b)
          WHEN 'CONTRAINDICATED_FOR'then apoc.create.relationship(a, 'CONTRAINDICATED_FOR', {}, b)
          WHEN 'EVIDENCE_OF'        THEN apoc.create.relationship(a, 'EVIDENCE_OF', {}, b)
          WHEN 'CONFIRMS'           THEN apoc.create.relationship(a, 'CONFIRMS', {}, b)
          WHEN 'REFUTES'            THEN apoc.create.relationship(a, 'REFUTES', {}, b)
          WHEN 'ASSOCIATED_WITH'    THEN apoc.create.relationship(a, 'ASSOCIATED_WITH', {}, b)
          WHEN 'IN_GENE'            THEN apoc.create.relationship(a, 'IN_GENE', {}, b)
          ELSE null
        END AS rel
      }
      RETURN 1
    }
    """
    # If you don't have APOC, use a simple CASE/FOREACH pattern instead (see below).
    tx.run(cy, rows=rels)

def upsert_relationships_no_apoc(tx, rels):
    cy = """
    UNWIND $rows AS row
    MATCH (a {id: row.from}), (b {id: row.to})
    FOREACH (_ IN CASE WHEN row.type='INDICATED_FOR' THEN [1] ELSE [] END |
      MERGE (a)-[:INDICATED_FOR]->(b)
    )
    FOREACH (_ IN CASE WHEN row.type='CONTRAINDICATED_FOR' THEN [1] ELSE [] END |
      MERGE (a)-[:CONTRAINDICATED_FOR]->(b)
    )
    FOREACH (_ IN CASE WHEN row.type='EVIDENCE_OF' THEN [1] ELSE [] END |
      MERGE (a)-[:EVIDENCE_OF]->(b)
    )
    FOREACH (_ IN CASE WHEN row.type='CONFIRMS' THEN [1] ELSE [] END |
      MERGE (a)-[:CONFIRMS]->(b)
    )
    FOREACH (_ IN CASE WHEN row.type='REFUTES' THEN [1] ELSE [] END |
      MERGE (a)-[:REFUTES]->(b)
    )
    FOREACH (_ IN CASE WHEN row.type='ASSOCIATED_WITH' THEN [1] ELSE [] END |
      MERGE (a)-[:ASSOCIATED_WITH]->(b)
    )
    FOREACH (_ IN CASE WHEN row.type='IN_GENE' THEN [1] ELSE [] END |
      MERGE (a)-[:IN_GENE]->(b)
    )
    """
    tx.run(cy, rows=rels)

def main():
    if len(sys.argv) < 5:
        print("Usage: python tools/load_core_ontology.py <bolt_url> <user> <password> <path_to_json>")
        sys.exit(1)

    uri, user, pwd, json_path = sys.argv[1:5]
    data = json.loads(pathlib.Path(json_path).read_text())

    driver = GraphDatabase.driver(uri, auth=(user, pwd), max_connection_lifetime=300)

    with driver.session() as sess:
        # Upsert entities by label
        mapping = [
            ("Disease",     data.get("diseases", []),     ["id","name","codeSystem","code"]),
            ("Syndrome",    data.get("syndromes", []),    ["id","name","codeSystem","code"]),
            ("Medication",  data.get("medications", []),  ["id","name","codeSystem","code","form","route"]),
            ("Observation", data.get("observations", []), ["id","code","value","unit","effTime","method"]),
            ("Test",        data.get("tests", []),        ["id","code","orderTime","status"]),
            ("ImagingStudy",data.get("imaging", []),      ["id","modality","bodySite","time"]),
            ("Procedure",   data.get("procedures", []),   ["id","code","time"]),
            ("AllergyIntolerance", data.get("allergies", []), ["id","substance","criticality"]),
            ("Gene",        data.get("genes", []),        ["id","symbol"]),
            ("Variant",     data.get("variants", []),     ["id","hgvs","clinvarId"]),
        ]

        for label, items, props in mapping:
            for batch in chunks(items, 500):
                sess.execute_write(upsert_entities, label, batch, props)

        # Relationships
        rels = data.get("relationships", [])
        for batch in chunks(rels, 500):
            # Choose one of the two, depending on APOC availability
            sess.execute_write(upsert_relationships_no_apoc, batch)
            # sess.execute_write(upsert_relationships, batch)  # requires APOC

    print("Seed load complete.")

if __name__ == "__main__":
    main()
