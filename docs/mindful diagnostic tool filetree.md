mindful-diagnostic-tool/  
├── README.md  
├── LICENSE  
├── requirements.txt  
├── pyproject.toml  
├── .env.example  
├── .gitignore

docs/  
├── architecture/  
│   ├── final-architecture.cypher  
│   ├── genome-schema.md  
│   ├── local-kg-schema.md  
│   ├── shared-kg-schema.md  
│   ├── event-sourcing-spec.md  
│   ├── mcp-tools-integration.md  
│   └── security-assessment.md  
├── research/  
│   ├── mindful-machines-overview.md  
│   ├── digital-genome-theory.md  
│   ├── gti-summary.md  
│   └── comparative-analysis.md  
├── api-docs/  
│   ├── openapi.yaml  
│   └── endpoints.md  
└── dev-notes/  
    ├── backlog.md  
    ├── changelog.md  
    └── roadmap.md

docs/  
├── architecture/  
│   ├── final-architecture.cypher  
│   ├── genome-schema.md  
│   ├── local-kg-schema.md  
│   ├── shared-kg-schema.md  
│   ├── event-sourcing-spec.md  
│   ├── mcp-tools-integration.md  
│   └── security-assessment.md  
├── research/  
│   ├── mindful-machines-overview.md  
│   ├── digital-genome-theory.md  
│   ├── gti-summary.md  
│   └── comparative-analysis.md  
├── api-docs/  
│   ├── openapi.yaml  
│   └── endpoints.md  
└── dev-notes/  
    ├── backlog.md  
    ├── changelog.md  
    └── roadmap.md

src/  
├── \_\_init\_\_.py  
├── app.py  
├── config/  
│   ├── \_\_init\_\_.py  
│   ├── settings.py  
│   └── logging.yaml  
├── core/  
│   ├── \_\_init\_\_.py  
│   ├── genome\_runner.py  
│   ├── event\_bus.py  
│   ├── orchestrator.py  
│   ├── mcp\_agent.py  
│   └── security.py  
├── data\_ingestion/  
│   ├── \_\_init\_\_.py  
│   ├── loaders/  
│   │   ├── ehr\_loader.py  
│   │   ├── imaging\_loader.py  
│   │   └── lab\_results\_loader.py  
│   ├── normalizers/  
│   │   ├── ontology\_mapper.py  
│   │   └── fhir\_normalizer.py  
│   └── pipelines.py  
├── knowledge\_graph/  
│   ├── \_\_init\_\_.py  
│   ├── local\_kg.py  
│   ├── shared\_kg.py  
│   ├── cypher\_queries.py  
│   └── schema\_validator.py  
├── ml\_models/  
│   ├── \_\_init\_\_.py  
│   ├── diagnostic\_model.py  
│   ├── symptom\_checker.py  
│   └── risk\_predictor.py  
├── agents/  
│   ├── \_\_init\_\_.py  
│   ├── intake\_agent.py  
│   ├── evidence\_agent.py  
│   ├── summarizer\_agent.py  
│   ├── oracle\_agent.py  
│   └── coordinator\_agent.py  
├── api/  
│   ├── \_\_init\_\_.py  
│   ├── routes/  
│   │   ├── patients.py  
│   │   ├── diagnosis.py  
│   │   ├── knowledge.py  
│   │   └── admin.py  
│   └── middleware.py  
├── ui/  
│   ├── \_\_init\_\_.py  
│   ├── web/  
│   │   ├── components/  
│   │   ├── pages/  
│   │   ├── static/  
│   │   └── templates/  
│   └── cli/  
│       ├── \_\_init\_\_.py  
│       └── commands.py  
└── utils/  
    ├── \_\_init\_\_.py  
    ├── helpers.py  
    ├── validators.py  
    └── timers.py

tests/  
├── \_\_init\_\_.py  
├── test\_core.py  
├── test\_data\_ingestion.py  
├── test\_knowledge\_graph.py  
├── test\_ml\_models.py  
├── test\_agents.py  
└── test\_api.py

data/  
├── core-medical-ontology.json  
├── sample-patients.json  
├── sample-ehr.csv  
└── kg-seed-data.cypher

scripts/  
├── init\_db.py  
├── load\_seed\_data.py  
├── export\_kg.py  
└── run\_diagnostics.py

deployment/  
├── docker/  
│   ├── Dockerfile  
│   └── docker-compose.yaml  
├── k8s/  
│   ├── deployment.yaml  
│   ├── service.yaml  
│   └── ingress.yaml  
└── ci-cd/  
    ├── github-actions.yaml  
    └── gitlab-ci.yaml

