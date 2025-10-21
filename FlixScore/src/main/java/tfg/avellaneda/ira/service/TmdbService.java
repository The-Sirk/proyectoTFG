package tfg.avellaneda.ira.service;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * API de conexión a TMDb. Contiene la lógica base de WebClient.
 *
 * @author Adrián
 */
@Service
public class TmdbService {

    private final WebClient webClient;
    // ¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡NO SUBIR LA KEY A GitHub!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // Más adelante se puede subir la key como variable a Cloud Run
    private final String apiKey = "pon_tu_key_aqui"; // reemplaza con tu key de TMDb
    private static final String BASE_URL = "https://api.themoviedb.org/3";

    public TmdbService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl(BASE_URL).build();
    }

    /**
     * Proporciona un RequestHeadersUriSpec para iniciar una petición GET.
     * Este es el punto de partida que usará BuscarPeliculasEnTMDb.
     */
    public WebClient.RequestHeadersUriSpec<?> getBaseRequest() {
        return webClient.get();
    }
    
    /**
     * Proporciona la API Key para que el servicio de búsqueda la añada al URI.
     */
    public String getApiKey() {
        return apiKey;
    }
}