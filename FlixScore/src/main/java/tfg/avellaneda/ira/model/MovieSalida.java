package tfg.avellaneda.ira.model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Modelo en Español de película, reconstruye la ruta del poster
 * es el modelo final con el que trabajamos.
 * 
 * @author Adrián
 */
public class MovieSalida {
    private int id;
    private String titulo;
    private String tituloOriginal;
    private String resumen;
    private String fechaEstreno;
    private double popularidad;
    private double puntucionMedia;
    private int recuentoVotos;
    private String rutaPoster;
    private String rutaFondo;
    private String idiomaOriginal;
    private List<Integer> generosIds;

    private static final String rutaBaseURLPoster = "https://image.tmdb.org/t/p/w500";

    private static final DateTimeFormatter INPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter OUTPUT_FORMAT = DateTimeFormatter.ofPattern("dd-MM-yyyy");

    // Getters y setters normales
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String title) {
        this.titulo = title;
    }

    public String getTituloOriginal() {
        return tituloOriginal;
    }

    public void setTituloOriginal(String originalTitle) {
        this.tituloOriginal = originalTitle;
    }

    public String getResumen() {
        return resumen;
    }

    public void setResumen(String overview) {
        this.resumen = overview;
    }

    public String getFechaEstreno() {
        return fechaEstreno;
    }

    public void setFechaEstreno(String releaseDate) {
        if (releaseDate != null && !releaseDate.trim().isEmpty()) {
            try {
                // Parsear la cadena de entrada
                LocalDate date = LocalDate.parse(releaseDate, INPUT_FORMAT);
                // Formatear a la cadena de salida deseada
                this.fechaEstreno = date.format(OUTPUT_FORMAT);
            } catch (Exception e) {
                // Si el formato de entrada no es el esperado, almacenamos la cadena original
                this.fechaEstreno = releaseDate;
                System.err.println("Error al parsear la fecha: " + releaseDate + ". Usando el valor original.");
            }
        } else {
            this.fechaEstreno = releaseDate;
        }
    }

    public double getPopularidad() {
        return popularidad;
    }

    public void setPopularidad(double popularity) {
        this.popularidad = popularity;
    }

    public double getPuntucionMedia() {
        return puntucionMedia;
    }

    public void setPuntucionMedia(double voteAverage) {
        this.puntucionMedia = voteAverage;
    }

    public int getRecuentoVotos() {
        return recuentoVotos;
    }

    public void setRecuentoVotos(int voteCount) {
        this.recuentoVotos = voteCount;
    }

    public String getRutaPoster() {
        if (rutaPoster == null)
            return null;
        return rutaBaseURLPoster + rutaPoster;
    }

    public void setRutaPoster(String posterPath) {
        this.rutaPoster = posterPath;
    }

    public String getRutaFondo() {
        if (rutaFondo == null)
            return null;
        return rutaBaseURLPoster + rutaFondo;
    }

    public void setRutaFondo(String backdropPath) {
        this.rutaFondo = backdropPath;
    }

    public String getIdiomaOriginal() {
        return idiomaOriginal;
    }

    public void setIdiomaOriginal(String originalLanguage) {
        this.idiomaOriginal = originalLanguage;
    }

    public List<Integer> getGenerosIds() {
        return generosIds;
    }

    public void setGenerosIds(List<Integer> genreIds) {
        this.generosIds = genreIds;
    }
}
