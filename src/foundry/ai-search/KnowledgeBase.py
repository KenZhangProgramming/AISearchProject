from azure.identity import DefaultAzureCredential
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndexerDataUserAssignedIdentity,
    KnowledgeBase,
    KnowledgeBaseAzureOpenAIModel,
    KnowledgeSourceReference,
    AzureOpenAIVectorizerParameters,
    AzureBlobKnowledgeSource, 
    AzureBlobKnowledgeSourceParameters,
    KnowledgeSourceContentExtractionMode, 
    KnowledgeSourceIngestionParameters,
    KnowledgeSourceAzureOpenAIVectorizer
)

chat_completion_model_params = AzureOpenAIVectorizerParameters(
    resource_url = "{aoai_resource_url}",
    deployment_name = "{aoai_deployment_name_chat_completion}",
    model_name = "{aoai_model_name_chat_completion}"
)

embedding_model_params = AzureOpenAIVectorizerParameters(
    resource_url = "{aoai_resource_url}",
    deployment_name = "{aoai_deployment_name_embedding}",
    model_name = "{aoai_model_name_embedding}"
)

index_client = SearchIndexClient(endpoint = "{search_url}", credential = DefaultAzureCredential())

knowledge_source = AzureBlobKnowledgeSource(
    name = "ks-BankAi-searches",
    description = "This knowledge source pulls information about bank AI searches from a blob storage container.",
    encryption_key = None,
    azure_blob_parameters = AzureBlobKnowledgeSourceParameters(
        connection_string = "{storage_account_connection_string}",
        container_name = "bank-ai-searches-content",
        folder_path = None,
        is_adls_gen2 = False,
        ingestion_parameters = KnowledgeSourceIngestionParameters(
            disable_image_verbalization = False,
            chat_completion_model = KnowledgeBaseAzureOpenAIModel(
                azure_open_ai_parameters = chat_completion_model_params
            ),
            embedding_model = KnowledgeSourceAzureOpenAIVectorizer(
                azure_open_ai_parameters = embedding_model_params
            ),
            content_extraction_mode = KnowledgeSourceContentExtractionMode.MINIMAL,
            ingestion_schedule = None,
            ingestion_permission_options = None
        )
    )
)

index_client.create_or_update_knowledge_source(knowledge_source)
print(f"Knowledge source '{knowledge_source.name}' created or updated successfully.")

knowledge_base = KnowledgeBase(
    name = "bank-ai-search",
    description = "This knowledge base handles questions about Bank AI Search content from the configured storage source.",
    retrieval_instructions = "Use the Bank AI Search knowledge source to retrieve relevant banking AI search content.",
    knowledge_sources = [
        KnowledgeSourceReference(name = "ks-BankAi-searches"),
    ],
    models = [KnowledgeBaseAzureOpenAIModel(azure_open_ai_parameters = chat_completion_model_params)],
    encryption_key = None
)

index_client.create_or_update_knowledge_base(knowledge_base)
print(f"Knowledge base '{knowledge_base.name}' created or updated successfully.")