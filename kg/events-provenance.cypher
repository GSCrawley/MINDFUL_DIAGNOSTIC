CREATE CONSTRAINT event_id IF NOT EXISTS FOR (e:Event) REQUIRE e.id IS UNIQUE;
CREATE INDEX event_type IF NOT EXISTS FOR (e:Event) ON (e.type);
CREATE INDEX event_ts IF NOT EXISTS FOR (e:Event) ON (e.ts);

CREATE CONSTRAINT service_id IF NOT EXISTS FOR (s:Service) REQUIRE s.id IS UNIQUE;

MERGE (runner:Service {id:'svc:genome-runner'}) SET runner.kind='Controller';
MERGE (wfm:Service {id:'svc:workflow-manager'}) SET wfm.kind='Orchestrator';
MERGE (oracle:Service {id:'svc:cognizing-oracle'}) SET oracle.kind='Oracle';
MERGE (reflector:Service {id:'svc:reflector'}) SET reflector.kind='Analyzer';
MERGE (fhir:Service {id:'svc:fhir-adapter'}) SET fhir.kind='Adapter';
MERGE (agent:Service:Agent {id:'agent:evidence-summarizer'}) SET agent.mode='propose_only';

// Event relationships (documentation)
// (Event)-[:EMITS]->(Observation|Inference|Action|Decision)
// (Event)-[:ON_ENTITY]->(Patient|Encounter|Diagnosis|Evidence|...)
// (Event)-[:BY_SERVICE]->(Service)
// (Event)-[:FOLLOWS]->(Event)
