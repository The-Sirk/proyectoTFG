package tfg.avellaneda.ira.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import tfg.avellaneda.ira.model.ModeloUsuario;
import tfg.avellaneda.ira.service.UsuarioService;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PutMapping;


/**
 * Controlador REST para gestionar los usuarios.
 * 
 * @author Israel
 * 
 * TODO: Añadir manejo de excepciones personalizado.
 */


@RestController
@RequestMapping("/api/v1/usuarios")
public class UsuarioController {

    @Autowired
    UsuarioService usuarioService;

    @GetMapping("{id}")
    public String getUsuarioByID(@PathVariable String UsuarioID) {
        try {
            return usuarioService.getUsuarioById(UsuarioID);
        } catch (Exception e) {
            return "Error al obtener el usuario: " + e.getMessage();
        }
    }

    @GetMapping("")
    public String getAll() {
        try {
            return usuarioService.getAll();
        } catch (Exception e) {
            return "Error al obtener los usuarios: " + e.getMessage();
        }
    }

    @GetMapping("{nick}")
    public String getByNick(@PathVariable String nick) {
        try {
            return usuarioService.getUsuarioByNick(nick);
        } catch (Exception e) {
            return "Error al obtener el usuario por nick: " + e.getMessage();
        }
    }

    @DeleteMapping("{id}")
    public String deleteUsuario(@PathVariable String id) {
        try {
            return usuarioService.deleteUsuario(id);
        } catch (Exception e) {
            return "Error al eliminar el usuario: " + e.getMessage();
        }
    }

    @PostMapping("")
    public String addUsuario(@RequestBody ModeloUsuario usuario) {
        try {
            return usuarioService.addUsuario(usuario);
        } catch (Exception e) {
            return "Error al añadir el usuario: " + e.getMessage(); 
        }
    }

    @PutMapping("{id}")
    public String updateUsuario(@PathVariable String id, @RequestBody ModeloUsuario usuario) {
        try {
            return usuarioService.updateUsuario(id, usuario);
        } catch (Exception e) {
            return "Error al actualizar el usuario: " + e.getMessage();
        }
    }
    

}
