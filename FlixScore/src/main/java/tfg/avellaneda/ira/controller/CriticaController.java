package tfg.avellaneda.ira.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.service.CriticaService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

/**
 * Controlador REST para gestionar las críticas de películas.
 * Proporciona endpoints para crear, recuperar por usuario y por película.
 * @author Israel
 * 
 * TODO: Añadir manejo de excepciones personalizado.
 */


@RestController
@RequestMapping("/api/v1/criticas")
public class CriticaController {

    @Autowired
    CriticaService criticaService;

    @GetMapping("")
    public String getAll() {
        try {
            return criticaService.getAll();
        } catch (Exception e) {
            return "Error al obtener las críticas: " + e.getMessage();
        }
    }
    @GetMapping("{id}")
    public String getByCriticaID(@PathVariable String CriticalID) {
        try {
            return criticaService.getCriticaById(CriticalID);
        } catch (Exception e) {
            return "Error al obtener la crítica: " + e.getMessage();
        }
    }

    @GetMapping("/user/{userId}") 
    public String getByUserId(@PathVariable String userId) {
        try {
            return criticaService.getCriticasByUserId(userId);
        } catch (Exception e) {
            return "Error al obtener las críticas del usuario: " + e.getMessage();
        }
    }

    @GetMapping("/pelicula/{peliculaId}")
    public String getByPeliculaId(@PathVariable String peliculaId) {
        try {
            return criticaService.getCriticasByPeliculaId(peliculaId);
        } catch (Exception e) {
            return "Error al obtener las críticas de la película: " + e.getMessage();
        }
    }

    @PostMapping("")
    public String addCritica(@RequestBody ModeloCritica critica) {
        try {
            return criticaService.addCritica(critica);
        } catch (Exception e) {
            return "Error al añadir la crítica: " + e.getMessage();
        }
    }
    
}
