package api

import (
	"net/http"
	"sync"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type ServerImplementation struct {
	Lock sync.Mutex
	DB   *gorm.DB
}

func (s *ServerImplementation) GetMovieByName(ctx echo.Context, name string) error {
	return nil
}

func (s *ServerImplementation) GetMovieBygenre(ctx echo.Context, genre string) error {
	return nil
}

func (s *ServerImplementation) GetMovieByCastMember(ctx echo.Context, castmember string) error {
	return nil
}

func (s *ServerImplementation) GetMovieByYear(ctx echo.Context, year int64) error {

	var movies []Movie
	tx := s.DB.Where("year = ?", year).Find(&movies)
	if tx.Error != nil {
		return ctx.JSON(http.StatusBadRequest, tx.Error)
	}
	return ctx.JSON(http.StatusOK, movies)
}

func (s *ServerImplementation) UploadMovie(ctx echo.Context) error {

	var newMovie Movie
	err := ctx.Bind(&newMovie)
	if err != nil {
		return err
	}
	s.Lock.Lock()
	defer s.Lock.Unlock()

	tx := s.DB.Create(&newMovie)
	if tx.Error != nil {
		return tx.Error
	}
	return ctx.JSON(http.StatusOK, "")
}
