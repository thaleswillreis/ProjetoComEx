# Projeto Data Warehouse ComEx

## Description

This is a didactic project that extracts product data from an e-commerce website using the Scrapy library. The extracted data is processed and stored in a database using SQLite for later analysis.

## Project Structure

The project is structured according to the Scrapy standard and in addition to the standard folder structure, it contains the following main files:

### File: `mercadolivre.py`

This file contains the code for the Scrapy spider responsible for extracting product information from the Mercado Livre search results list.

#### Code:

```python
import scrapy

class MercadolivreSpider(scrapy.Spider):
    name = "mercadolivre"
    start_urls = ["https://lista.mercadolivre.com.br/intelbras"]
    pag_inicial = 1
    pag_final = 10

    def parse(self, response):
        """
        Faz o parse da resposta HTML obtida a partir da URL inicial. 
        Extrai informações dos itens listados na página e gera um dicionário com os dados extraídos.
        """

        # Seleciona todos os itens na página de resultados de busca
        itens = response.css('div.ui-search-result__content')

        for item in itens:
            # Extrai os preços e centavos dos itens
            precos = item.css('span.andes-money-amount__fraction::text').getall()
            centavos = item.css('span.andes-money-amount__cents::text').getall()

            # Gera um dicionário com as informações extraídas de cada item
            yield {
                'produto': item.css('h2.ui-search-item__title::text').get(),
                'avaliação': item.css('span.ui-search-reviews__rating-number::text').get(),
                'avaliações_qtd': item.css('span.ui-search-reviews__amount::text').get(),
                'preco': precos[1] if len(precos) > 1 else None,
                'preco_centavos': centavos[1] if len(centavos) > 1 else None
            }

        # Verifica se há mais páginas a serem processadas
        if self.pag_inicial < self.pag_final:
            # Extrai o link para a próxima página de resultados
            if proxima_pagina := response.css(
                'li.andes-pagination__button.andes-pagination__button--next a::attr(href)'
            ).get():
                self.pag_inicial += 1
                # Faz uma requisição para a próxima página e chama o método parse novamente
                yield scrapy.Request(url=proxima_pagina, callback=self.parse)
```
### File: `data_transformation.py`

This file contains the code responsible for processing the extracted data, adding metadata, cleaning the data and storing it in a SQLite database.

#### Code:

```python
import pandas as pd
import sqlite3
import datetime as dt

class MercadoLivreData:
    def __init__(self, json_path, db_path, source_url):
        """
        Inicializa a classe com os caminhos para o arquivo JSON, banco de dados e URL de origem.
        """
        self.json_path = json_path
        self.db_path = db_path
        self.source_url = source_url
        self.df = None

    def load_data(self):
        """
        Carrega os dados do arquivo JSON.
        """
        self.df = pd.read_json(self.json_path, lines=True)

    def add_metadata(self):
        """
        Adiciona metadados ao DataFrame.
        """
        self.df['_source'] = self.source_url
        self.df['_data_coleta'] = dt.datetime.now()

    def clean_data(self):
        """
        Limpa e processa os dados do DataFrame.
        """
        self.df['avaliações_qtd'] = self.df['avaliações_qtd'].str.replace('[\(\)]', '', regex=True)
        self.df['avaliações_qtd'] = self.df['avaliações_qtd'].fillna(0).astype(int)

        self.df['avaliação'] = self.df['avaliação'].fillna(0).astype(float)
        self.df['preco'] = self.df['preco'].fillna(0).astype(float)
        self.df['preco_centavos'] = self.df['preco_centavos'].fillna(0).astype(float)

        self.df['preco_produto'] = self.df['preco'] + self.df['preco_centavos'] / 100
        self.df.drop('preco_centavos', axis=1, inplace=True)
        self.df.drop('preco', axis=1, inplace=True)

    def save_to_sql(self):
        """
        Salva os dados no banco de dados SQLite.
        """
        con = sqlite3.connect(self.db_path)
        self.df.to_sql('prod_mercado_livre', con=con, if_exists='replace', index=False)
        con.close()

    def process(self):
        """
        Executa o fluxo completo de processamento dos dados:
        - Carrega os dados
        - Adiciona metadados
        - Limpa os dados
        - Salva os dados no banco de dados
        """
        self.load_data()
        self.add_metadata()
        self.clean_data()
        self.save_to_sql()

if __name__ == "__main__":
    json_path = '../../Dados/itensML.jsonl'
    db_path = '../../Dados/scrp_ml.db'
    source_url = 'https://lista.mercadolivre.com.br/intelbras'

    ml_data = MercadoLivreData(json_path, db_path, source_url)
    ml_data.process()
```
## Features

* **Data Extraction** : Uses Scrapy to extract information from Mercado Livre products, such as product name, rating, number of ratings and price.
* **Data Transformation** : Processes the extracted data, adds metadata and cleans the information.
* **Data Storage** : Saves the processed data in an SQLite database for later analysis.

## Results

The extracted and processed data is stored in an SQLite database (`scrp_ml.db`) and can be used for various market and pricing analyses.

## Running the Project

1. **Install Dependencies** : Make sure you have the necessary libraries installed (`scrapy`, `pandas`, `sqlite3`).
2. **Run the Spider** : Navigate to the project directory and run the `scrapy crawl mercadolivre` command to start collecting data.
3. **Process the Data**: After collection, run the `data_transformation.py` script to process and save the data to the SQLite database.

#### Required Dependencies and Versions

The software and libraries used in the project had the following versions:

* Python - Version: 3.12.4
* Pandas - Version: 2.2.2
* Scrapy - Version: 2.11.2
* SQLite - Version: 3.41.2

**Note:** for more details see the "requirements.txt" file

**Related links:**

* [Debian Linux](https://www.debian.org/index.pt.html)
* [VSCode](https://code.visualstudio.com/)
* [Python](https://www.python.org/)
* [Jupyter](https://jupyter.org/)
* [Pandas](https://pandas.pydata.org/)
* [Scrapy](https://scrapy.org/)
* [SQLite](https://www.sqlite.org/)
* [Git](https://git-scm.com/)

## Problems encountered

The code may encounter problems when running using different versions of the language and libraries. Make sure that the versions listed in the "Required Dependencies and Versions" item are correctly installed.

If there is already a development environment with different versions in use on the machine being used, a good alternative would be to create a virtual development environment. If in doubt, follow the link to the documentation.
[Virtual environments and packages](https://docs.python.org/pt-br/3/tutorial/venv.html)

## Contribution

Contributions are welcome! Feel free to open issues and pull requests in the project repository.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/thaleswillreis/Data_Pipeline_Web_Scraping?tab=MIT-1-ov-file) file for more details.