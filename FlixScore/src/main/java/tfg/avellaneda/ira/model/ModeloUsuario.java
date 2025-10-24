package tfg.avellaneda.ira.model;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.google.cloud.firestore.annotation.DocumentId;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModeloUsuario {

    @DocumentId
    private String DocumentID;
    private String correo;
    @JsonAlias("imagen_perfil")
    private String imagenPerfil;
    private String nick;
    @JsonAlias("peliculas_criticadas")
    private List<String> peliculasCriticadas;
    @JsonAlias("peliculas_favoritas")
    private List<String> peliculasFavoritas;
    @JsonAlias("peliculas_vistas")
    private List<String> peliculasVistas;
    
    
    
}
