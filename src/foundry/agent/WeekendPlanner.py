from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import PromptAgentDefinition, MCPTool, StructuredInputDefinition
from azure.identity import DefaultAzureCredential

# Provide agent configuration details
credential = DefaultAzureCredential()
mcp_endpoint = "{search_service_endpoint}/knowledgebases/{knowledge_base_name}/mcp?api-version=2025-11-01-preview"
project_endpoint = "{project_endpoint}"
knowledgebase_connection_name = "{knowledgebase_connection_name}"
agent_name = "{agent_name}"
agent_model = "{deployed_LLM}"

# Create project client
project_client = AIProjectClient(endpoint = project_endpoint, credential = credential)

instructions = """
You answer questions about what to do on the weekend.

This is the process for answering the question:
1.  Always ask what is the current date if the user does not provide it.
2. The scraped weekend events AI Search index contains events for this coming weekend.  Always search this index to see what is happening this weekend.
3. Answer the users question using the scraped weekend events.  Only use these events unless the user explicitly says otherwise.  
4. Revise your answer by following these rules.  
  - Do not say that you're using scraped event listings
  - Do not mention events that are not happening this coming weekend
"""

mcp_kb_tool = MCPTool(
    server_label = "kb_weekend_events",
    server_url = mcp_endpoint,
    require_approval = "never",
    project_connection_id = knowledgebase_connection_name
)

agent = project_client.agents.create_version(
    agent_name = agent_name,
    definition = PromptAgentDefinition(
        model = agent_model,
        instructions = instructions,
        tools = [mcp_kb_tool]
    )
)

print(f"Agent '{agent_name}' created or updated successfully.")