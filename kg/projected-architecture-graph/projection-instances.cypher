// =========================
// Build Graph – Instances
// Reflects your end product tree at a high level (planning DB).
// Safe to re-run (MERGE).
// =========================

// ---- System & Domains ----
MERGE (sys:System {id:'sys:mindful-diagnostic-tool'}) SET sys.name='Mindful Diagnostic Tool', sys.owner='ClinicalAI';

MERGE (domRuntime:Domain {id:'dom:runtime'})   SET domRuntime.name='Runtime Platform';
MERGE (domKG:Domain      {id:'dom:kg'})        SET domKG.name='Knowledge & Memory';
MERGE (domAgents:Domain  {id:'dom:agents'})    SET domAgents.name='Agentic Helpers';
MERGE (domUI:Domain      {id:'dom:ui'})        SET domUI.name='Clinician UX';
MERGE (domEvent:Domain   {id:'dom:eventing'})  SET domEvent.name='Eventing';
MERGE (domSecurity:Domain{id:'dom:security'})  SET domSecurity.name='Security & Compliance';
MERGE (domBuild:Domain   {id:'dom:build-graph'}) SET domBuild.name='Build Projection (Planning DB)';

MERGE (domRuntime)-[:OWNED_BY]->(sys);
MERGE (domKG)-[:OWNED_BY]->(sys);
MERGE (domAgents)-[:OWNED_BY]->(sys);
MERGE (domUI)-[:OWNED_BY]->(sys);
MERGE (domEvent)-[:OWNED_BY]->(sys);
MERGE (domSecurity)-[:OWNED_BY]->(sys);
MERGE (domBuild)-[:OWNED_BY]->(sys);

// ---- Environments ----
MERGE (envDev:Environment  {id:'env:dev'})  SET envDev.name='Development';
MERGE (envProd:Environment {id:'env:prod'}) SET envProd.name='Production';

// ---- Goals & Policies (teleonomy) ----
MERGE (gSafety:Goal  {id:'goal:safety'})  SET gSafety.name='Patient Safety', gSafety.priority=1;
MERGE (gQuality:Goal {id:'goal:quality'}) SET gQuality.name='Diagnostic Quality', gQuality.priority=2;
MERGE (gCost:Goal    {id:'goal:cost'})    SET gCost.name='Cost Efficiency', gCost.priority=3;

MERGE (pUnapproved:Policy {id:'policy:unapproved-therapy'}) SET pUnapproved.name='No Unapproved Therapy', pUnapproved.type='hard';
MERGE (pPHI:Policy       {id:'policy:hipaa-minimize'})     SET pPHI.name='PHI Minimization', pPHI.type='hard';

MERGE (gSafety)-[:ENFORCES]->(pUnapproved);
MERGE (gSafety)-[:ENFORCES]->(pPHI);

// ---- Data stores / eventing / knowledge bases (planning view) ----
MERGE (kgRuntime:KnowledgeBase:DataStore {id:'ds:neo4j-runtime'}) 
  SET kgRuntime.name='Neo4j – Runtime KG', kgRuntime.kind='Neo4j', kgRuntime.purpose='Shared Medical KG + Local Memory + Provenance';
MERGE (kgBuild:KnowledgeBase:DataStore {id:'ds:neo4j-build-graph'}) 
  SET kgBuild.name='Neo4j – Build Graph', kgBuild.kind='Neo4j', kgBuild.purpose='High-level projection (planning only)';

MERGE (bus:EventBus:DataStore {id:'ds:event-bus'}) 
  SET bus.name='Kafka/Redpanda', bus.kind='EventBus', bus.topics=['observations','inferences','decisions','audits'];

// ---- Services (core runtime) ----
MERGE (svcRunner:Service {id:'svc:genome-runner'})   SET svcRunner.name='Genome Runner';
MERGE (svcWFM:Service    {id:'svc:workflow-manager'}) SET svcWFM.name='Workflow Manager';
MERGE (svcOracle:Service {id:'svc:cognizing-oracle'}) SET svcOracle.name='Cognizing Oracle';
MERGE (svcReflector:Service {id:'svc:reflector'})     SET svcReflector.name='Reflector';
MERGE (svcFHIR:Adapter:Service {id:'svc:fhir-adapter'}) SET svcFHIR.name='FHIR Adapter';
MERGE (svcImaging:Adapter:Service {id:'svc:imaging-adapter'}) SET svcImaging.name='Imaging Adapter';
MERGE (svcGenomics:Adapter:Service {id:'svc:genomics-adapter'}) SET svcGenomics.name='Genomics Adapter';

// Grouping & environments
FOREACH (s IN [svcRunner,svcWFM,svcOracle,svcReflector,svcFHIR,svcImaging,svcGenomics] |
  MERGE (s)-[:GROUPED_IN]->(domRuntime)
  MERGE (s)-[:RUNS_IN]->(envDev)
  MERGE (s)-[:RUNS_IN]->(envProd)
);

// ---- UI ----
MERGE (ui:UI {id:'ui:clinician-console'}) SET ui.name='Clinician Console (React)';
MERGE (ui)-[:GROUPED_IN]->(domUI);

// ---- Agents (bounded, propose-only) ----
MERGE (agentSumm:Agent {id:'agent:evidence-summarizer'}) SET agentSumm.name='Evidence Summarizer', agentSumm.mode='propose_only';
MERGE (agentSumm)-[:GROUPED_IN]->(domAgents);

// ---- Tools (MCP) ----
MERGE (toolSumm:Tool {id:'tool:med-summarize'})  SET toolSumm.name='med-summarize';
MERGE (toolUMLS:Tool {id:'tool:umls-normalizer'}) SET toolUMLS.name='umls-normalizer';
MERGE (agentSumm)-[:USES_TOOL]->(toolSumm);
MERGE (agentSumm)-[:USES_TOOL]->(toolUMLS);

// ---- APIs (planned) ----
MERGE (apiDiag:API {id:'api:diagnosis'}) SET apiDiag.name='Diagnosis API';
MERGE (apiKG:API   {id:'api:kg'})        SET apiKG.name='Knowledge API';
MERGE (svcWFM)-[:EXPOSES_API]->(apiDiag);
MERGE (svcOracle)-[:EXPOSES_API]->(apiDiag);
MERGE (svcWFM)-[:EXPOSES_API]->(apiKG);
MERGE (svcOracle)-[:EXPOSES_API]->(apiKG);
MERGE (ui)-[:CALLS]->(apiDiag);
MERGE (ui)-[:CALLS]->(apiKG);

// ---- Workflows (from genome v1) ----
MERGE (wfTriage:Workflow {id:'wf:triage'})             SET wfTriage.name='Triage';
MERGE (wfEvidence:Workflow {id:'wf:evidence-gathering'}) SET wfEvidence.name='Evidence Gathering';
MERGE (wfRare:Workflow {id:'wf:rare-disease-flag'})      SET wfRare.name='Rare Disease Flag';

MERGE (svcWFM)-[:IMPLEMENTS]->(wfTriage);
MERGE (svcWFM)-[:IMPLEMENTS]->(wfEvidence);
MERGE (svcWFM)-[:IMPLEMENTS]->(wfRare);
MERGE (svcOracle)-[:IMPLEMENTS]->(wfTriage);
MERGE (agentSumm)-[:IMPLEMENTS]->(wfEvidence); // propose-only step

// ---- Governance on workflows & services ----
MERGE (wfTriage)-[:GOVERNED_BY]->(pUnapproved);
MERGE (wfTriage)-[:GOVERNED_BY]->(pPHI);
MERGE (svcOracle)-[:GOVERNED_BY]->(pUnapproved);
MERGE (svcOracle)-[:GOVERNED_BY]->(pPHI);

// ---- Data flows (planning) ----
MERGE (svcFHIR)-[:WRITES_TO]->(kgRuntime);
MERGE (svcImaging)-[:WRITES_TO]->(kgRuntime);
MERGE (svcGenomics)-[:WRITES_TO]->(kgRuntime);

MERGE (svcWFM)-[:READS_FROM]->(kgRuntime);
MERGE (svcOracle)-[:READS_FROM]->(kgRuntime);
MERGE (svcReflector)-[:READS_FROM]->(kgRuntime);

MERGE (svcWFM)-[:PRODUCES {topics:['observations','decisions']}]->(bus);
MERGE (svcOracle)-[:PRODUCES {topics:['inferences','audits']}]->(bus);
MERGE (svcReflector)-[:PRODUCES {topics:['audits']}]->(bus);
MERGE (svcFHIR)-[:PRODUCES {topics:['observations']}]->(bus);

// Consumers (logical)
MERGE (svcOracle)-[:CONSUMES {topics:['observations']}]->(bus);
MERGE (svcWFM)-[:CONSUMES {topics:['observations','inferences']}]->(bus);
MERGE (svcReflector)-[:CONSUMES {topics:['audits']}]->(bus);

// ---- Dependencies (build/runtime) ----
MERGE (svcRunner)-[:DEPENDS_ON]->(svcWFM);
MERGE (svcRunner)-[:DEPENDS_ON]->(svcOracle);
MERGE (svcRunner)-[:DEPENDS_ON]->(svcReflector);

MERGE (svcWFM)-[:CALLS]->(svcOracle);
MERGE (svcWFM)-[:DEPENDS_ON]->(bus);
MERGE (svcOracle)-[:DEPENDS_ON]->(kgRuntime);
MERGE (svcReflector)-[:DEPENDS_ON]->(kgRuntime);
MERGE (svcFHIR)-[:DEPENDS_ON]->(kgRuntime);

MERGE (ui)-[:DEPENDS_ON]->(apiDiag);
MERGE (ui)-[:DEPENDS_ON]->(apiKG);

// ---- Artifacts & Releases (link docs/specs/code to components) ----
MERGE (artGenome:Artifact {id:'art:genome-v1-yaml'}) SET artGenome.kind='spec', artGenome.path='genome/genome-v1.yaml';
MERGE (svcRunner)-[:CONTAINS]->(artGenome);
MERGE (svcWFM)-[:CONTAINS]->(:Artifact {id:'art:wfm:triage.py', kind:'code', path:'services/workflow-manager/src/wfm/workflows/triage.py'});
MERGE (svcOracle)-[:CONTAINS]->(:Artifact {id:'art:oracle:schema', kind:'contract', path:'services/cognizing-oracle/contracts/oracle-io.schema.json'});
MERGE (ui)-[:CONTAINS]->(:Artifact {id:'art:ui:App.tsx', kind:'code', path:'ui/clinician-console/src/App.tsx'});

MERGE (relV1:Release {id:'rel:genome-v1'}) SET relV1.name='Genome v1';
MERGE (artGenome)-[:RELEASES]->(relV1);

// ---- Planning link: Build Graph mirrors Runtime KG (conceptual) ----
MERGE (kgBuild)-[:MIRRORS]->(kgRuntime);
