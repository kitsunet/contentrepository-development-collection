@fixtures
Feature: Creation of nodes underneath hidden nodes WITH content dimensions

  If we create new nodes belonging to an aggregate, underneath of hidden nodes, they must be marked as "hidden" as well; i.e. they
  must have the proper restriction edges as well.

  Node structure created in BG:
  - rn-identifier (root node)
  -- na-identifier (name=text1) [de, en] <== HIDDEN!
  --- cna-identifier (name=text2) [de]

  Background:
    Given I have the following content dimensions:
      | Identifier | Default | Values | Generalizations |
      | language   | de      | de, en |                 |
    And the command CreateWorkspace is executed with payload:
      | Key                     | Value         | Type |
      | workspaceName           | live          |      |
      | contentStreamIdentifier | cs-identifier | Uuid |
      | rootNodeIdentifier      | rn-identifier | Uuid |
    And I have the following NodeTypes configuration:
    """
    Neos.ContentRepository:Root: {}
    'Neos.ContentRepository.Testing:Content':
      properties:
        text:
          type: string
    """
    When the command "CreateNodeAggregateWithNode" is executed with payload:
      | Key                     | Value                                  | Type                |
      | contentStreamIdentifier | cs-identifier                          | Uuid                |
      | nodeAggregateIdentifier | na-identifier                          | Uuid                |
      | dimensionSpacePoint     | {"language": "de"}                     | DimensionSpacePoint |
      | nodeTypeName            | Neos.ContentRepository.Testing:Content |                     |
      | nodeIdentifier          | node-identifier                        | Uuid                |
      | parentNodeIdentifier    | rn-identifier                          | Uuid                |
      | nodeName                | text1                                  |                     |

    And the command "CreateNodeAggregateWithNode" is executed with payload:
      | Key                     | Value                                  | Type                |
      | contentStreamIdentifier | cs-identifier                          | Uuid                |
      | nodeAggregateIdentifier | cna-identifier                         | Uuid                |
      | dimensionSpacePoint     | {"language": "de"}                     | DimensionSpacePoint |
      | nodeTypeName            | Neos.ContentRepository.Testing:Content |                     |
      | nodeIdentifier          | cnode-identifier                       | Uuid                |
      | parentNodeIdentifier    | node-identifier                        | Uuid                |
      | nodeName                | text2                                  |                     |

    And the command "AddNodeToAggregate" is executed with payload:
      | Key                     | Value              | Type                |
      | contentStreamIdentifier | cs-identifier      | Uuid                |
      | nodeAggregateIdentifier | na-identifier      | Uuid                |
      | dimensionSpacePoint     | {"language": "en"} | DimensionSpacePoint |
      | nodeIdentifier          | node2-identifier   | Uuid                |
      | parentNodeIdentifier    | rn-identifier      | Uuid                |
      | nodeName                | text1              |                     |

    And the command "HideNode" is executed with payload:
      | Key                          | Value                                    | Type |
      | contentStreamIdentifier      | cs-identifier                            | Uuid |
      | nodeAggregateIdentifier      | na-identifier                            | Uuid |
      | affectedDimensionSpacePoints | [{"language": "de"}, {"language": "en"}] | json |

  Scenario: When a new node is added to an already existing aggregate underneath a hidden node, this one should be hidden as well
    When the command "AddNodeToAggregate" is executed with payload:
      | Key                     | Value              | Type                |
      | contentStreamIdentifier | cs-identifier      | Uuid                |
      | nodeAggregateIdentifier | cna-identifier     | Uuid                |
      | dimensionSpacePoint     | {"language": "en"} | DimensionSpacePoint |
      | nodeIdentifier          | cnode2-identifier  | Uuid                |
      | parentNodeIdentifier    | node2-identifier   | Uuid                |
      | nodeName                | text2              |                     |

    And the graph projection is fully up to date

    When I am in content stream "[cs-identifier]" and Dimension Space Point {"language": "en"}
    Then I expect a node identified by aggregate identifier "[cna-identifier]" not to exist in the subgraph


  Scenario: When a node is removed from an aggregate, the hidden flag should be cleared as well. We test this by recreating the node the hidden flag is ORIGINATING from; and expecting it to be *visible*
    When the command "AddNodeToAggregate" is executed with payload:
      | Key                     | Value              | Type                |
      | contentStreamIdentifier | cs-identifier      | Uuid                |
      | nodeAggregateIdentifier | cna-identifier     | Uuid                |
      | dimensionSpacePoint     | {"language": "en"} | DimensionSpacePoint |
      | nodeIdentifier          | cnode2-identifier  | Uuid                |
      | parentNodeIdentifier    | rn-identifier      | Uuid                |
      | nodeName                | text2              |                     |

    And the command RemoveNodesFromAggregate was published with payload:
      | Key                     | Value               | Type                   |
      | contentStreamIdentifier | cs-identifier       | Uuid                   |
      | nodeAggregateIdentifier | na-identifier       | Uuid                   |
      | dimensionSpacePointSet  | [{"language":"en"}] | DimensionSpacePointSet |

    And the command "AddNodeToAggregate" is executed with payload:
      | Key                     | Value              | Type                |
      | contentStreamIdentifier | cs-identifier      | Uuid                |
      | nodeAggregateIdentifier | na-identifier      | Uuid                |
      | dimensionSpacePoint     | {"language": "en"} | DimensionSpacePoint |
      | nodeIdentifier          | cnode2-identifier  | Uuid                |
      | parentNodeIdentifier    | rn-identifier      | Uuid                |
      | nodeName                | text1              |                     |

    And the graph projection is fully up to date

    When I am in content stream "[cs-identifier]" and Dimension Space Point {"language": "en"}
    Then I expect a node identified by aggregate identifier "[na-identifier]" to exist in the subgraph


  Scenario: When a node is removed from an aggregate, the hidden flag should be cleared as well. We test this by recreating a node UNDERNEATH a hidden node; and expecting it to be *hidden* (because it inherits again the permissions from the parent) - but the test has to run through!
    When the command "AddNodeToAggregate" is executed with payload:
      | Key                     | Value              | Type                |
      | contentStreamIdentifier | cs-identifier      | Uuid                |
      | nodeAggregateIdentifier | cna-identifier     | Uuid                |
      | dimensionSpacePoint     | {"language": "en"} | DimensionSpacePoint |
      | nodeIdentifier          | cnode2-identifier  | Uuid                |
      | parentNodeIdentifier    | node2-identifier   | Uuid                |
      | nodeName                | text2              |                     |

    And the command RemoveNodesFromAggregate was published with payload:
      | Key                     | Value               | Type                   |
      | contentStreamIdentifier | cs-identifier       | Uuid                   |
      | nodeAggregateIdentifier | cna-identifier      | Uuid                   |
      | dimensionSpacePointSet  | [{"language":"en"}] | DimensionSpacePointSet |

    And the command "AddNodeToAggregate" is executed with payload:
      | Key                     | Value              | Type                |
      | contentStreamIdentifier | cs-identifier      | Uuid                |
      | nodeAggregateIdentifier | cna-identifier     | Uuid                |
      | dimensionSpacePoint     | {"language": "en"} | DimensionSpacePoint |
      | nodeIdentifier          | cnode2-identifier  | Uuid                |
      | parentNodeIdentifier    | node2-identifier   | Uuid                |
      | nodeName                | text2              |                     |

    And the graph projection is fully up to date

    When I am in content stream "[cs-identifier]" and Dimension Space Point {"language": "en"}
    Then I expect a node identified by aggregate identifier "[cna-identifier]" not to exist in the subgraph

    When VisibilityConstraints are set to "withoutRestrictions"
    Then I expect a node identified by aggregate identifier "[cna-identifier]" to exist in the subgraph
