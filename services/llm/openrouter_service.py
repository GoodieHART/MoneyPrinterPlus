import requests
from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI

from config.config import my_config
from services.llm.llm_service import MyLLMService
from tools.utils import must_have_value


class OpenRouterService(MyLLMService):
    def __init__(self):
        super().__init__()
        self.OPENROUTER_API_KEY = my_config['llm']['OpenRouter']['api_key']
        self.OPENROUTER_MODEL_NAME = my_config['llm']['OpenRouter']['model_name']
        self.OPENROUTER_API_BASE = my_config['llm']['OpenRouter']['base_url']
        must_have_value(self.OPENROUTER_API_KEY, "Please set OpenRouter key")
        must_have_value(self.OPENROUTER_MODEL_NAME, "Please set OpenRouter model")
        must_have_value(self.OPENROUTER_API_BASE, "Please set OpenRouter base_url")

    def generate_content(self, topic: str, prompt_template: PromptTemplate, language: str = None, length: str = None):
        llm = ChatOpenAI(
            openai_api_key=self.OPENROUTER_API_KEY,
            model_name=self.OPENROUTER_MODEL_NAME,
            base_url=self.OPENROUTER_API_BASE,
        )
        chain = prompt_template | llm | StrOutputParser()
        description = chain.invoke({"topic": topic, "language": language, "length": length})
        return description.strip()

    def list_models(self):
        """
        Retrieve available model names from OpenRouter.
        Returns a list of model IDs.
        """
        url = f"{self.OPENROUTER_API_BASE.rstrip('/')}/v1/models"
        headers = {
            "Authorization": f"Bearer {self.OPENROUTER_API_KEY}",
            "Content-Type": "application/json"
        }
        try:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            # OpenRouter returns models under 'data'
            models = [model['id'] for model in data.get('data', [])]
            return models
        except Exception as e:
            print(f"Failed to fetch models from OpenRouter: {e}")
            return []
