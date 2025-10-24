package tfg.avellaneda.ira.model;

import java.util.List;

/**
 * Modelo en Español de película, reconstruye la ruta del poster
 * es el modelo final con el que trabajamos.
 * @author Adrián
 */
public class MovieSalida {
    private int id;
    private String title;
    private String originalTitle;
    private String overview;
    private String releaseDate;
    private double popularity;
    private double voteAverage;
    private int voteCount;
    private String posterPath;
    private String backdropPath;
    private String originalLanguage;
    private List<Integer> genreIds;

    private static final String rutaBaseURLPoster = "https://image.tmdb.org/t/p/w500";

    // Getters y setters normales
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getOriginalTitle() { return originalTitle; }
    public void setOriginalTitle(String originalTitle) { this.originalTitle = originalTitle; }

    public String getOverview() { return overview; }
    public void setOverview(String overview) { this.overview = overview; }

    public String getReleaseDate() { return releaseDate; }
    public void setReleaseDate(String releaseDate) { this.releaseDate = releaseDate; }

    public double getPopularity() { return popularity; }
    public void setPopularity(double popularity) { this.popularity = popularity; }

    public double getVoteAverage() { return voteAverage; }
    public void setVoteAverage(double voteAverage) { this.voteAverage = voteAverage; }

    public int getVoteCount() { return voteCount; }
    public void setVoteCount(int voteCount) { this.voteCount = voteCount; }

    public String getPosterPath() {
        if (posterPath == null) return null;
        return rutaBaseURLPoster + posterPath;
    }

    public void setPosterPath(String posterPath) { this.posterPath = posterPath; }

    public String getBackdropPath() {
        if (backdropPath == null) return null;
        return rutaBaseURLPoster + backdropPath;
    }

    public void setBackdropPath(String backdropPath) { this.backdropPath = backdropPath; }

    public String getOriginalLanguage() { return originalLanguage; }
    public void setOriginalLanguage(String originalLanguage) { this.originalLanguage = originalLanguage; }

    public List<Integer> getGenreIds() { return genreIds; }
    public void setGenreIds(List<Integer> genreIds) { this.genreIds = genreIds; }
}
