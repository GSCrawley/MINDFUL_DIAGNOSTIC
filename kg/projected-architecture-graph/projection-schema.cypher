// =========================
// Build Graph – Schema (Neo4j 5.x)
// =========================

// ---- Node keys / constraints (single labels) ----
CREATE CONSTRAINT IF NOT EXISTS FOR (n:System)        REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Domain)        REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Service)       REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Module)        REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Adapter)       REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Agent)         REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:UI)            REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:API)           REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Workflow)      REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Goal)          REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Policy)        REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:DataStore)     REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:EventBus)      REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:KnowledgeBase) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Environment)   REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Artifact)      REQUIRE n.id IS UNIQUE;   // code/doc/spec
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Release)       REQUIRE n.id IS UNIQUE;   // versions
CREATE CONSTRAINT IF NOT EXISTS FOR (n:Tool)          REQUIRE n.id IS UNIQUE;   // MCP tools
CREATE CONSTRAINT IF NOT EXISTS FOR (n:BuildTask)     REQUIRE n.id IS UNIQUE;   // project mgmt

// ---- Helpful indexes ----
CREATE INDEX IF NOT EXISTS FOR (n:Service) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR (n:Workflow) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR (n:Policy) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR (n:DataStore) ON (n.kind);

// ---- Relationship vocabulary (documentation) ----
// OWNED_BY:   Component → System/Domain owner
// RUNS_IN:    Component → Environment (dev/stage/prod)
// GROUPED_IN: Component → Domain (logical grouping)
// IMPLEMENTS: Module/Service → Workflow (capability)
// EXPOSES_API:Service/UI → API
// CALLS:      Service/Module → Service/Module
// DEPENDS_ON: Component → Component (build/runtime dep)
// READS_FROM / WRITES_TO: Component → DataStore/KnowledgeBase/EventBus
// PRODUCES / CONSUMES:    Component ↔ EventBus topics (modeled via properties too)
// GOVERNED_BY: Component/Workflow → Policy
// ENFORCES:   Goal → Policy
// TRIGGERS:   Workflow/Component → Workflow (or step)
// CONTAINS:   System/Service → Module/Artifact (composition)
// USES_TOOL:  Agent/Service → Tool (e.g., MCP)
// RELEASES:   System/Service/Artifact → Release
// MIRRORS:    Build-graph object → Runtime object (cross-DB concept marker)

// No creation is needed for rel-types; we just document the allowed set here.
