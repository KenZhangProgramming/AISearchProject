from functools import lru_cache

from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from azure.search.documents.indexes.models import (
    SearchableField,
    SearchField,
    SearchFieldDataType,
    SimpleField,
)
from langchain_community.vectorstores.azuresearch import AzureSearch
from langchain_openai import AzureChatOpenAI, AzureOpenAIEmbeddings

from .config import get_settings


@lru_cache
def get_credential() -> DefaultAzureCredential:
    return DefaultAzureCredential()


@lru_cache
def get_llm() -> AzureChatOpenAI:
    s = get_settings()
    token_provider = get_bearer_token_provider(
        get_credential(), "https://cognitiveservices.azure.com/.default"
    )
    return AzureChatOpenAI(
        azure_endpoint=s.azure_openai_endpoint,
        api_version=s.azure_openai_api_version,
        azure_deployment=s.azure_openai_chat_deployment,
        azure_ad_token_provider=token_provider,
        temperature=0.2,
    )


@lru_cache
def get_embeddings() -> AzureOpenAIEmbeddings:
    s = get_settings()
    token_provider = get_bearer_token_provider(
        get_credential(), "https://cognitiveservices.azure.com/.default"
    )
    return AzureOpenAIEmbeddings(
        azure_endpoint=s.azure_openai_endpoint,
        api_version=s.azure_openai_api_version,
        azure_deployment=s.azure_openai_embedding_deployment,
        azure_ad_token_provider=token_provider,
    )


@lru_cache
def get_vector_store() -> AzureSearch:
    s = get_settings()
    cred = get_credential()

    # AzureSearch accepts a callable that returns a fresh AAD access token
    # for the Azure AI Search data plane.
    def token_supplier() -> str:
        return cred.get_token("https://search.azure.com/.default").token

    return AzureSearch(
        azure_search_endpoint=s.azure_search_endpoint,
        azure_search_key=None,  # use AAD via DefaultAzureCredential
        index_name=s.azure_search_index,
        embedding_function=get_embeddings().embed_query,
        # Map LangChain's expected fields to the actual schema produced by
        # the Knowledge Base indexer (chunk_id / chunk / text_vector / title).
        fields=[
            SimpleField(
                name="chunk_id",
                type=SearchFieldDataType.String,
                key=True,
                filterable=True,
            ),
            SearchableField(
                name="chunk",
                type=SearchFieldDataType.String,
            ),
            SearchField(
                name="text_vector",
                type=SearchFieldDataType.Collection(SearchFieldDataType.Single),
                searchable=True,
                vector_search_dimensions=3072,
                vector_search_profile_name="ks-bank-ai-searches-index-vector-search-profile",
            ),
            SearchableField(
                name="title",
                type=SearchFieldDataType.String,
                filterable=True,
            ),
        ],
        azure_ad_access_token_provider=token_supplier,
    )
