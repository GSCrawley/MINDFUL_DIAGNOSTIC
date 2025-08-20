// --- CONSTRAINTS ---
CREATE CONSTRAINT node_service IF NOT EXISTS FOR (n:Service) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_component IF NOT EXISTS FOR (n:Component) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_policy IF NOT EXISTS FOR (n:Policy) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_goal IF NOT EXISTS FOR (n:Goal) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_workflow IF NOT EXISTS FOR (n:Workflow) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_event IF NOT EXISTS FOR (n:Event) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_tool IF NOT EXISTS FOR (n:MCPTool) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_agent IF NOT EXISTS FOR (n:Agent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT node_genome IF NOT EXISTS FOR (n:Genome) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT patient_id IF NOT EXISTS FOR (n:Patient) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT encounter_id IF NOT EXISTS FOR (n:Encounter) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT observation_id IF NOT EXISTS FOR (n:Observation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT diagnosis_id IF NOT EXISTS FOR (n:Diagnosis) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT disease_id IF NOT EXISTS FOR (n:Disease) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT evidence_id IF NOT EXISTS FOR (n:Evidence) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT medication_id IF NOT EXISTS FOR (n:Medication) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT test_id IF NOT EXISTS FOR (n:Test) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT procedure_id IF NOT EXISTS FOR (n:Procedure) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT allergy_id IF NOT EXISTS FOR (n:AllergyIntolerance) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT imaging_id IF NOT EXISTS FOR (n:ImagingStudy) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT gene_id IF NOT EXISTS FOR (n:Gene) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT variant_id IF NOT EXISTS FOR (n:Variant) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT local_pattern_id IF NOT EXISTS FOR (n:Pattern:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT local_summary_id IF NOT EXISTS FOR (n:Summary:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT local_toolrun_id IF NOT EXISTS FOR (n:ToolRun:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT local_proposal_id IF NOT EXISTS FOR (n:Proposal:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT local_review_id IF NOT EXISTS FOR (n:OracleReview:Local) REQUIRE n.id IS UNIQUE;

// Helpful indexes
CREATE INDEX IF NOT EXISTS FOR (n:Disease) ON (n.code);
CREATE INDEX IF NOT EXISTS FOR (n:Observation) ON (n.code);

// --- MANAGEMENT PLANE ---
MERGE (g:Genome {id:'genome:v1'})
  SET g.name='Mindful Diagnostic Tool – Genome v1', g.channel='signed';

MERGE (runner:Service {id:'svc:genome-runner'}) SET runner.kind='Controller';
MERGE (wfm:Service {id:'svc:workflow-manager'}) SET wfm.kind='Orchestrator';
MERGE (oracle:Service {id:'svc:cognizing-oracle'}) SET oracle.kind='Oracle';
MERGE (reflector:Service {id:'svc:reflector'}) SET reflector.kind='Analyzer';
MERGE (fhir:Service {id:'svc:fhir-adapter'}) SET fhir.kind='Adapter';
MERGE (events:Component {id:'cmp:event-store'}) SET events.type='EventBus', events.endpoint='kafka://eventbus:9092';
MERGE (kg:Component {id:'cmp:neo4j'}) SET kg.type='Database', kg.endpoint='bolt://neo4j:7687';

MERGE (wfTriage:Workflow {id:'wf:triage'}) SET wfTriage.name='Triage';
MERGE (wfEvidence:Workflow {id:'wf:evidence-gathering'}) SET wfEvidence.name='Evidence Gathering';
MERGE (wfRare:Workflow {id:'wf:rare-disease-flag'}) SET wfRare.name='Rare Disease Flag';

MERGE (toolSumm:MCPTool {id:'tool:med-summarize'}) SET toolSumm.desc='Medical evidence summarizer';
MERGE (toolUMLS:MCPTool {id:'tool:umls-normalizer'}) SET toolUMLS.desc='UMLS code normalizer';
MERGE (agent:Agent {id:'agent:evidence-summarizer'}) SET agent.mode='propose_only';
MERGE (agent)-[:USES_TOOL]->(toolSumm);
MERGE (agent)-[:USES_TOOL]->(toolUMLS);

MERGE (runner)-[:READS_GENOME]->(g);
MERGE (runner)-[:MANAGES]->(wfm);
MERGE (runner)-[:MANAGES]->(oracle);
MERGE (runner)-[:MANAGES]->(reflector);
MERGE (wfm)-[:EXECUTES]->(wfTriage);
MERGE (wfm)-[:EXECUTES]->(wfEvidence);
MERGE (wfm)-[:EXECUTES]->(wfRare);
MERGE (wfm)-[:EMITS_EVENTS_TO]->(events);
MERGE (oracle)-[:EMITS_EVENTS_TO]->(events);
MERGE (reflector)-[:EMITS_EVENTS_TO]->(events);
MERGE (fhir)-[:WRITES_TO]->(kg);
MERGE (oracle)-[:READS_FROM]->(kg);
MERGE (wfm)-[:READS_FROM]->(kg);
MERGE (reflector)-[:READS_FROM]->(kg);

// --- TELEONOMY & POLICIES ---
MERGE (goalSafety:Goal {id:'goal:safety'}) SET goalSafety.name='Patient Safety', goalSafety.priority=1;
MERGE (goalQuality:Goal {id:'goal:quality'}) SET goalQuality.name='Diagnostic Quality', goalQuality.priority=2;
MERGE (goalCost:Goal {id:'goal:cost'}) SET goalCost.name='Cost Efficiency', goalCost.priority=3;

MERGE (polUnapproved:Policy {id:'policy:unapproved-therapy'}) SET polUnapproved.type='hard';
MERGE (polPHI:Policy {id:'policy:hipaa-minimize'}) SET polPHI.type='hard';

MERGE (goalSafety)-[:ENFORCES]->(polUnapproved);
MERGE (goalSafety)-[:ENFORCES]->(polPHI);
MERGE (polUnapproved)-[:GOVERNS]->(oracle);
MERGE (polPHI)-[:GOVERNS]->(oracle);
MERGE (polPHI)-[:GOVERNS]->(events);

// --- SHARED MEDICAL KG: exemplar concepts ---
MERGE (flu:Disease {id:'dis:influenza'}) SET flu.name='Influenza', flu.codeSystem='SNOMEDCT', flu.code='6142004';
MERGE (ibuprofen:Medication {id:'med:ibuprofen'}) SET ibuprofen.codeSystem='RxNorm', ibuprofen.code='5640', ibuprofen.name='Ibuprofen';

// --- LOCAL KG: agent memory scaffold ---
MERGE (pat1:Pattern:Local {id:'pat:fever-cough-seasonal'}) 
  SET pat1.description='Fever+cough during influenza season', pat1.stats={precision:0.72, support:134};

// --- EVENT & PROVENANCE (worked example) ---
MERGE (pt:Patient {id:'pt-123'}) SET pt.sex='F', pt.birthDate='1985-03-01';
MERGE (enc:Encounter {id:'enc-55'}) SET enc.start='2025-08-10', enc.reasonCode='cough';
MERGE (pt)-[:HAS_ENCOUNTER]->(enc);

MERGE (obs:Observation {id:'obs-991'})
  SET obs.code='LOINC:LP21258-6', obs.value='38.8', obs.unit='C', obs.effTime='2025-08-10T15:10:00Z';
MERGE (enc)-[:HAS_OBSERVATION]->(obs);

// Observation event
MERGE (ev1:Event {id:'evt-obs-1'}) 
  SET ev1.type='ObservationEvent', ev1.ts=timestamp(), ev1.actor='svc:fhir-adapter', ev1.workflowId='wf:triage', ev1.stepId='step:retrieve';
MERGE (fhir)-[:EMITS]->(ev1);
MERGE (ev1)-[:ON_ENTITY]->(obs);

// Oracle inference
MERGE (ev2:Event {id:'evt-inf-1'})
  SET ev2.type='InferenceEvent', ev2.ts=timestamp(), ev2.actor='svc:cognizing-oracle', ev2.workflowId='wf:triage', ev2.stepId='step:hypothesize';
MERGE (oracle)-[:EMITS]->(ev2);
MERGE (ev2)-[:FOLLOWS]->(ev1);

// Proposed diagnosis (ranked)
MERGE (dx:Diagnosis {id:'dx-enc55-1'}) SET dx.time=date(), dx.certainty=0.71, dx.rank=1;
MERGE (enc)-[:HAS_DIAGNOSIS]->(dx);
MERGE (dx)-[:DIAGNOSES]->(flu);
MERGE (obs)-[:EVIDENCE_OF]->(flu);

// Human decision
MERGE (ev3:Event {id:'evt-dec-1'})
  SET ev3.type='DecisionEvent', ev3.ts=timestamp(), ev3.actor='clinician', ev3.workflowId='wf:triage', ev3.stepId='step:human-gate';
MERGE (ev3)-[:FOLLOWS]->(ev2);

// Agent proposal (local)
MERGE (tr:ToolRun:Local {id:'tr-001'}) SET tr.tool='tool:med-summarize', tr.duration_ms=1234;
MERGE (sum:Summary:Local {id:'sum-enc55-1'}) SET sum.text='Evidence supports influenza', sum.explainability=0.88, sum.coverage=0.65, sum.createdAt=datetime();
MERGE (tr)-[:PRODUCED]->(sum);

MERGE (prop:Proposal:Local {id:'prop-enc55-1'}) SET prop.type='PROMOTE_SUMMARY', prop.by='agent:evidence-summarizer', prop.createdAt=datetime();
MERGE (sum)<-[:ABOUT]-(prop);
MERGE (rev:OracleReview:Local {id:'rev-enc55-1'}) SET rev.result='approve', rev.confidence=0.82, rev.reasons=['adequate_evidence','no_policy_violation'];
MERGE (rev)-[:REVIEWS]->(prop);

// Promotion to shared Evidence
MERGE (evid:Evidence {id:'evid-enc55-1'}) SET evid.type='Summary', evid.source='agent:evidence-summarizer';
MERGE (sum)-[:PROMOTED_AS]->(evid);
MERGE (evid)-[:SUPPORTS]->(dx);

// Medication policy wiring
MERGE (ibuprofen)-[:INDICATED_FOR]->(flu);
MERGE (polUnapproved)-[:GOVERNS]->(ibuprofen);
