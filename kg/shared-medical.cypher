// Constraints
CREATE CONSTRAINT patient_id IF NOT EXISTS FOR (n:Patient) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT encounter_id IF NOT EXISTS FOR (n:Encounter) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT observation_id IF NOT EXISTS FOR (n:Observation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT test_id IF NOT EXISTS FOR (n:Test) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT imaging_id IF NOT EXISTS FOR (n:ImagingStudy) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT medication_id IF NOT EXISTS FOR (n:Medication) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT procedure_id IF NOT EXISTS FOR (n:Procedure) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT allergy_id IF NOT EXISTS FOR (n:AllergyIntolerance) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT disease_id IF NOT EXISTS FOR (n:Disease) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT syndrome_id IF NOT EXISTS FOR (n:Syndrome) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT gene_id IF NOT EXISTS FOR (n:Gene) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT variant_id IF NOT EXISTS FOR (n:Variant) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT diagnosis_id IF NOT EXISTS FOR (n:Diagnosis) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT evidence_id IF NOT EXISTS FOR (n:Evidence) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT policy_id IF NOT EXISTS FOR (n:Policy) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT goal_id IF NOT EXISTS FOR (n:Goal) REQUIRE n.id IS UNIQUE;

// Helpful indexes
CREATE INDEX disease_code IF NOT EXISTS FOR (n:Disease) ON (n.code);
CREATE INDEX syndrome_code IF NOT EXISTS FOR (n:Syndrome) ON (n.code);
CREATE INDEX observation_code IF NOT EXISTS FOR (n:Observation) ON (n.code);
CREATE INDEX test_code IF NOT EXISTS FOR (n:Test) ON (n.code);
CREATE INDEX medication_code IF NOT EXISTS FOR (n:Medication) ON (n.code);

// Relationships (doc)
# Patient Journey
# (Patient)-[:HAS_ENCOUNTER]->(Encounter)
# (Encounter)-[:HAS_OBSERVATION]->(Observation)
# (Encounter)-[:ORDERED_TEST]->(Test)
# (Encounter)-[:PERFORMED_PROCEDURE]->(Procedure)
# (Encounter)-[:ADMINISTERED_MEDICATION]->(Medication)
# (Patient)-[:HAS_ALLERGY]->(AllergyIntolerance)

# Reasoning & Governance
# (Observation)-[:EVIDENCE_OF]->(Disease|Syndrome)
# (Test)-[:CONFIRMS|REFUTES]->(Disease|Syndrome)
# (Medication)-[:INDICATED_FOR]->(Disease)
# (Medication)-[:CONTRAINDICATED_FOR]->(Disease|AllergyIntolerance)
# (Variant)-[:IN_GENE]->(Gene)
# (Variant)-[:ASSOCIATED_WITH]->(Disease|Syndrome)
# (Encounter)-[:HAS_DIAGNOSIS]->(Diagnosis)-[:DIAGNOSES]->(Disease|Syndrome)
# (Evidence)-[:SUPPORTS]->(Observation|Test|Diagnosis)
# (Evidence)-[:DERIVED_FROM]->(ImagingStudy|Variant|Procedure)
# (Policy)-[:GOVERNS]->(Medication|Procedure|Workflow|OracleRule)
# (Goal)-[:ENFORCES]->(Policy);

// Seed governance (optional)
MERGE (g:Goal {id:'goal:safety'}) SET g.name='Patient Safety', g.priority=1;
MERGE (p1:Policy {id:'policy:unapproved-therapy'}) SET p1.name='No Unapproved Therapy', p1.type='hard';
MERGE (p2:Policy {id:'policy:hipaa-minimize'}) SET p2.name='PHI Minimization', p2.type='hard';
MERGE (g)-[:ENFORCES]->(p1);
MERGE (g)-[:ENFORCES]->(p2);
