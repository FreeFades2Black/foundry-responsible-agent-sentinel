{
  "lenses": {
    "0": {
      "order": 0,
      "parts": {
        "0": {
          "position": {
            "x": 0,
            "y": 0,
            "colSpan": 6,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [],
            "type": "Extension/HubsExtension/PartType/MarkdownPart",
            "settings": {
              "content": {
                "settings": {
                  "title": "Sentinel AI Foundry & Watchdog Intelligence",
                  "subtitle": "Audited RAI Agent, Upstream Monitoring & Azure AI Infrastructure",
                  "content": "### 🛰️ Executive Enterprise AI Operations Center\n\nWelcome to the unified operations and financial governance dashboard for **Foundry Responsible Agent Sentinel** and **Repo Watchdog Agent**.\n\n* **Azure AI Foundry Hub & Project:** Autonomous agent grounded in Azure AI Search with strict multi-point Responsible AI (RAI) prompt shields.\n* **Cognitive Compute:** GPT-4o orchestration with Text-Embedding-3-Large vectors.\n* **Perimeter Watchdog:** Rolling 24-hour upstream dependency telemetry and breaking-change detection.\n\n---\n#### ⚡ Quick Actions & Live Portals\n* 🌐 [Launch Live Tactical Watchdog UI](https://freefades2black.github.io/repo-watchdog-agent/)\n* 🧠 [Open Azure AI Foundry Studio](https://ai.azure.com/)\n* 🔍 [Open Azure AI Search Service](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Search%2FsearchServices)\n* 💰 [Open Azure Cost Management & Billing](https://portal.azure.com/#blade/Microsoft_Azure_CostManagement_Menu/CostAnalysis)"
                }
              }
            }
          }
        },
        "1": {
          "position": {
            "x": 6,
            "y": 0,
            "colSpan": 3,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "scope",
                "value": "/subscriptions/${subscription_id}"
              },
              {
                "name": "view",
                "value": {
                  "chart": "Area",
                  "accumulated": "true",
                  "dateRange": "ThisMonth",
                  "query": {
                    "type": "ActualCost",
                    "dataSet": {
                      "granularity": "Daily",
                      "aggregation": {
                        "totalCost": {
                          "name": "PreTaxCost",
                          "function": "Sum"
                        }
                      }
                    }
                  }
                }
              }
            ],
            "type": "Extension/Microsoft_Azure_CostManagement/PartType/CostAnalysisPinPart",
            "settings": {
              "title": "Accumulated Month-to-Date Spend"
            }
          }
        },
        "2": {
          "position": {
            "x": 9,
            "y": 0,
            "colSpan": 3,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "scope",
                "value": "/subscriptions/${subscription_id}"
              },
              {
                "name": "view",
                "value": {
                  "chart": "Bar",
                  "accumulated": "false",
                  "dateRange": "ThisMonth",
                  "query": {
                    "type": "ActualCost",
                    "dataSet": {
                      "granularity": "None",
                      "aggregation": {
                        "totalCost": {
                          "name": "PreTaxCost",
                          "function": "Sum"
                        }
                      },
                      "grouping": [
                        {
                          "type": "Dimension",
                          "name": "ServiceName"
                        }
                      ]
                    }
                  }
                }
              }
            ],
            "type": "Extension/Microsoft_Azure_CostManagement/PartType/CostAnalysisPinPart",
            "settings": {
              "title": "Spend Breakdown by Service"
            }
          }
        },
        "3": {
          "position": {
            "x": 0,
            "y": 3,
            "colSpan": 4,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "queryInputs",
                "value": {
                  "timespan": {
                    "duration": "P7D"
                  },
                  "chartType": 0,
                  "metrics": [
                    {
                      "name": "TotalCalls",
                      "aggregationType": 1
                    },
                    {
                      "name": "SuccessCalls",
                      "aggregationType": 1
                    },
                    {
                      "name": "BlockedCalls",
                      "aggregationType": 1
                    }
                  ]
                }
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "title": "AI Compute: Model Invocations & RAI Filters"
            }
          }
        },
        "4": {
          "position": {
            "x": 4,
            "y": 3,
            "colSpan": 4,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "queryInputs",
                "value": {
                  "timespan": {
                    "duration": "P7D"
                  },
                  "chartType": 0,
                  "metrics": [
                    {
                      "name": "SearchQueriesPerSecond",
                      "aggregationType": 4
                    },
                    {
                      "name": "SearchLatency",
                      "aggregationType": 4
                    }
                  ]
                }
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "title": "Knowledge Base: Search QPS & Latency"
            }
          }
        },
        "5": {
          "position": {
            "x": 8,
            "y": 3,
            "colSpan": 4,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "queryInputs",
                "value": {
                  "timespan": {
                    "duration": "P7D"
                  },
                  "chartType": 0,
                  "metrics": [
                    {
                      "name": "ServiceApiHit",
                      "aggregationType": 1
                    },
                    {
                      "name": "ServiceApiResult",
                      "aggregationType": 1
                    }
                  ]
                }
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "title": "Security & Identity: Key Vault API Operations"
            }
          }
        },
        "6": {
          "position": {
            "x": 0,
            "y": 6,
            "colSpan": 4,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "queryInputs",
                "value": {
                  "timespan": {
                    "duration": "P7D"
                  },
                  "chartType": 0,
                  "metrics": [
                    {
                      "name": "UsedCapacity",
                      "aggregationType": 4
                    }
                  ]
                }
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "title": "Storage Footprint: Blob Used Capacity"
            }
          }
        },
        "7": {
          "position": {
            "x": 4,
            "y": 6,
            "colSpan": 4,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "queryInputs",
                "value": {
                  "timespan": {
                    "duration": "P7D"
                  },
                  "chartType": 0,
                  "metrics": [
                    {
                      "name": "Transactions",
                      "aggregationType": 1
                    },
                    {
                      "name": "Ingress",
                      "aggregationType": 1
                    },
                    {
                      "name": "Egress",
                      "aggregationType": 1
                    }
                  ]
                }
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "title": "Storage Compute: Transactions & I/O"
            }
          }
        },
        "8": {
          "position": {
            "x": 8,
            "y": 6,
            "colSpan": 4,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "queryInputs",
                "value": {
                  "timespan": {
                    "duration": "P7D"
                  },
                  "chartType": 0,
                  "metrics": [
                    {
                      "name": "Heartbeat",
                      "aggregationType": 1
                    }
                  ]
                }
              }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
              "title": "Telemetry: Audit Log Ingestion Health"
            }
          }
        },
        "9": {
          "position": {
            "x": 0,
            "y": 9,
            "colSpan": 12,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [],
            "type": "Extension/HubsExtension/PartType/MarkdownPart",
            "settings": {
              "content": {
                "settings": {
                  "title": "Architecture & Operational Run Matrix",
                  "subtitle": "Summary of Deployed Resources and Execution Profiles",
                  "content": "| Resource Component | Azure Service | Operational Purpose | Compute / Storage Profile |\n| :--- | :--- | :--- | :--- |\n| **AI Foundry Hub & Project** | `Microsoft.MachineLearningServices` | Agent workflow coordination & model hosting | Managed Serverless Compute |\n| **Cognitive Services Account** | `Microsoft.CognitiveServices` | GPT-4o & Text Embedding 3 execution | Token-based compute billing |\n| **Azure AI Search** | `Microsoft.Search/searchServices` | Vector search & Grounding Knowledge Base | Basic/Standard Dedicated Search Units |\n| **Blob Storage & Data Lake** | `Microsoft.Storage/storageAccounts` | Agent memory, dossiers, and grounding docs | LRS Hot/Cool Storage Tier |\n| **Key Vault** | `Microsoft.KeyVault/vaults` | Zero-trust secrets and managed identities | API transaction billing (negligible) |\n| **Log Analytics Workspace** | `Microsoft.OperationalInsights` | Security telemetry, red-team evaluations, and audits | Per-GB Ingestion Tier |\n| **Watchdog Sentinel Node** | `GitHub Pages / Linux Systemd` | Continuous 24h upstream monitoring & breaking checks | Zero-cost serverless hosting |"
                }
              }
            }
          }
        }
      }
    }
  },
  "metadata": {
    "model": {
      "timeRange": {
        "value": {
          "relative": {
            "duration": 24,
            "timeUnit": 1
          }
        },
        "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
      },
      "filterLocale": {
        "value": "en-us"
      },
      "filters": {
        "value": {
          "MsPortalFx_TimeRange": {
            "model": {
              "format": "utc",
              "granularity": "auto",
              "relative": "24h"
            },
            "displayCache": {
              "name": "UTC",
              "value": "Past 24 hours"
            },
            "filteredItemId": "ResourceGroup"
          }
        }
      }
    }
  }
}
