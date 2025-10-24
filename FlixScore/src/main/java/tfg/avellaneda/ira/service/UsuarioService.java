package tfg.avellaneda.ira.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;

import tfg.avellaneda.ira.model.ModeloUsuario;
import tfg.avellaneda.ira.repositories.UsuarioRepository;


/**
 * Service REST para gestionar los usuarios.
 * 
 * @author Israel
 * 
 * TODO: Añadir manejo de excepciones personalizado.
 * TODO: Añadir verificacion de datos y validaciones.
 */


@Service
public class UsuarioService {
    
    @Autowired
    UsuarioRepository repo;
    
    @Autowired
    ObjectMapper mapper;

    public String getAll(){
        try {
            List<ModeloUsuario> usuarios = repo.getAll()
                    .get()
                    .toObjects(ModeloUsuario.class);
            return mapper.writeValueAsString(usuarios);
        } catch (Exception e) {
            System.out.println("Error al obtener los usuarios: " + e.getMessage());
            return "Error";
        }
    }

    public String getUsuarioById(String usuarioId) {
        try {
            ModeloUsuario usuario = repo.getUsuarioById(usuarioId)
                    .get()
                    .toObject(ModeloUsuario.class);
            return mapper.writeValueAsString(usuario);
        } catch (Exception e) {
            System.out.println("Error al obtener el usuario: " + e.getMessage());
            return "Error";
        }
    }

    public String getUsuarioByNick(String nick) {
        try {
            List<ModeloUsuario> usuarios = repo.getUsuarioByNick(nick)
                    .get()
                    .toObjects(ModeloUsuario.class);
            return mapper.writeValueAsString(usuarios);
        } catch (Exception e) {
            System.out.println("Error al obtener el usuario por nick: " + e.getMessage());
            return "Error";
        }
    }

    public String deleteUsuario(String usuarioId) {
        try {
            repo.deleteUsuario(usuarioId).get();
            return "Usuario eliminado correctamente.";
        } catch (Exception e) {
            System.out.println("Error al eliminar el usuario: " + e.getMessage());
            return "Error al eliminar el usuario.";
        }
    }

    public String addUsuario(ModeloUsuario entity) {
        try {
            var futureDocRef = repo.addUsuario(entity);
            var docRef = futureDocRef.get();
            var future = docRef.get();
            var document = future.get();
            if (document.exists()) {
                ModeloUsuario creado = document.toObject(ModeloUsuario.class);
                return mapper.writeValueAsString(creado);
            } else {
                return null;
            }
        } catch (Exception e) {
            System.out.println("Error al añadir el usuario: " + e.getMessage());
            return null;
        }
    }

    public String updateUsuario(String usuarioId, ModeloUsuario usuario) {
        try {
            repo.updateUsuario(usuarioId, usuario).get();
            return "Usuario actualizado correctamente.";
        } catch (Exception e) {
            System.out.println("Error al actualizar el usuario: " + e.getMessage());
            return "Error al actualizar el usuario.";
        }
    }

}
