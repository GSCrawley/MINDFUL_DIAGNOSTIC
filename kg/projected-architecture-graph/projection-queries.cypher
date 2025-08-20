// =========================
// Build Graph – Useful Queries
// =========================

// 1) Show end-to-end flow for a workflow (services, data stores, event bus).
:param wf_id => 'wf:triage';
MATCH (wf:Workflow {id:$wf_id})
OPTIONAL MATCH (s:Service)-[:IMPLEMENTS]->(wf)
OPTIONAL MATCH (s)-[:READS_FROM|WRITES_TO|PRODUCES|CONSUMES]->(d)
RETURN wf, s, d;

// 2) Policy coverage: which components and workflows are governed by which policies?
MATCH (p:Policy)<-[:GOVERNED_BY]-(x)
RETURN p.name AS policy, labels(x) AS kind, x.name AS name
ORDER BY policy, kind, name;

// 3) Data lineage (planning): which components read/write the Runtime KG?
MATCH (ds:DataStore {id:'ds:neo4j-runtime'})<-[:READS_FROM|WRITES_TO]-(c)
RETURN c.name AS component, head(labels(c)) AS kind, type(relationships((c)-[:READS_FROM|WRITES_TO]->(ds))[0]) AS mode
ORDER BY component;

// 4) Event bus producers/consumers (with topics).
MATCH (bus:EventBus)<-[r:PRODUCES|CONSUMES]-(c)
RETURN c.name AS component, type(r) AS role, r.topics AS topics
ORDER BY role, component;

// 5) Dependency impact: if Oracle changes, what’s affected upstream/downstream?
MATCH (src:Service {id:'svc:cognizing-oracle'})
OPTIONAL MATCH p = (src)-[:DEPENDS_ON|CALLS*1..2]-(other)
RETURN nodes(p) AS chain
LIMIT 50;

// 6) UI surface map: what does the Clinician Console call, and what do those call?
MATCH (ui:UI {id:'ui:clinician-console'})-[:DEPENDS_ON|CALLS]->(a)
OPTIONAL MATCH path = (a)-[:EXPOSES_API|CALLS|DEPENDS_ON*1..2]->(downstream)
RETURN ui, a, downstream, path LIMIT 50;

// 7) Environment matrix: where each component runs.
MATCH (c)-[:RUNS_IN]->(env:Environment)
RETURN env.name AS env, c.name AS component, labels(c) AS kind
ORDER BY env, component;

// 8) Who implements each workflow (and governed policies)?
MATCH (wf:Workflow)<-[:IMPLEMENTS]-(s:Service)
OPTIONAL MATCH (wf)-[:GOVERNED_BY]->(p:Policy)
RETURN wf.name AS workflow, collect(DISTINCT s.name) AS implementers, collect(DISTINCT p.name) AS policies;

// 9) What MCP tools are in play and who uses them?
MATCH (t:Tool)<-[:USES_TOOL]-(a)
RETURN t.name AS tool, collect(DISTINCT a.name) AS users;

// 10) Artifacts by component (code/spec contracts).
MATCH (c)-[:CONTAINS]->(a:Artifact)
RETURN c.name AS component, a.kind AS kind, a.path AS path
ORDER BY component, kind, path;
