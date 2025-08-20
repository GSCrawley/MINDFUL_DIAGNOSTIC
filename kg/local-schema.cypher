// Local KG (per-service/agent memory)

// Constraints
CREATE CONSTRAINT local_item_id IF NOT EXISTS FOR (n:LocalItem) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT pattern_id IF NOT EXISTS FOR (n:Pattern:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT proposal_id IF NOT EXISTS FOR (n:Proposal:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT summary_id IF NOT EXISTS FOR (n:Summary:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT toolrun_id IF NOT EXISTS FOR (n:ToolRun:Local) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT review_id IF NOT EXISTS FOR (n:OracleReview:Local) REQUIRE n.id IS UNIQUE;

// Nodes
// Pattern(id, scope='local', description, stats)
// Summary(id, text, explainability, coverage, createdAt)
// Proposal(id, type, by, createdAt)
// ToolRun(id, tool, args_hash, duration_ms, redactions)
// OracleReview(id, result, reasons[], policyViolations[], confidence)

// Relationships
// (ToolRun)-[:PRODUCED]->(Summary|Proposal)
// (Proposal)-[:ABOUT]->(Summary|Pattern)
// (Proposal)-[:PROPOSES]->(:SharedPlaceholder {target:'...'})
// (OracleReview)-[:REVIEWS]->(Proposal)
// Promotion
// (Summary:Local)-[:PROMOTED_AS]->(Evidence:Shared)
// (Pattern:Local)-[:PROMOTED_AS]->(Pattern:Shared)
