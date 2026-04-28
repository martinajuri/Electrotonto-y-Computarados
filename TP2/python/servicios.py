import requests

def consultar_indice_gini(codigo_pais='ARG'):
    """
    Obtiene el valor GINI más reciente para un país desde la API del Banco Mundial.
    """
    url_base = "https://api.worldbank.org/v2/country"
    indicador = "SI.POV.GINI"
    query = f"{url_base}/{codigo_pais}/indicator/{indicador}?format=json&per_page=100"
    
    try:
        respuesta = requests.get(query, timeout=10)
        respuesta.raise_for_status() # Lanza error si la web falla
        
        datos_json = respuesta.json()
        
        # El Banco Mundial devuelve una lista donde el segundo elemento [1] son los datos
        for registro in datos_json[1]:
            if registro['value'] is not None:
                anio = registro['date']
                valor_gini = registro['value']
                print(f"-> [API] Dato hallado: {codigo_pais} ({anio}) = {valor_gini}")
                return valor_gini
                
    except Exception as e:
        print(f"-> [ERROR] No se pudo conectar con la API: {e}")
    
    return None