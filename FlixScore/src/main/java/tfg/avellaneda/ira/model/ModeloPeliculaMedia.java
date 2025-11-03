package tfg.avellaneda.ira.model;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

/**
 * Modelo auxiliar para almacenar el ID de la película y su puntuación media
 * calculada
 * 
 * @author Adrián
 */
@Data
@NoArgsConstructor
@AllArgsConstructor(staticName = "of")
public class ModeloPeliculaMedia {

    private int peliculaID;
    private double puntuacionMedia;

}