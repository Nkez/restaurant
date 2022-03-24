package repository

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	"github.com/rs/zerolog/log"
	"restaurant-assistant/internal/domain"
	"strings"
)

type DishPostgres struct {
	db *sqlx.DB
}

func NewDishPostgres(db *sqlx.DB) *DishPostgres {
	return &DishPostgres{db: db}
}

func (s *DishPostgres) CreateDish(input domain.Dish, restaurantId string) (string, error) {
	fmt.Printf("%+v\n", input)
	createDishQuery := fmt.Sprintf(`INSERT INTO dishes (type, cost, name, image,
			cooking_time, weight, description, status, restaurant_id) 
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`)
	var id string
	input.RestaurantId = restaurantId
	row := s.db.QueryRow(createDishQuery, input.Type, input.Cost, input.Name, input.Image, input.CookingTime,
		input.Weight, input.Description, input.Status, restaurantId)
	if err := row.Scan(&id); err != nil {
		log.Error().Err(err).Msg("")
	}
	return id, nil
}

func (s *DishPostgres) UpdateDish(id string, input domain.UpdateDish) error {
	setValues := make([]string, 0)
	args := make([]interface{}, 0)
	argId := 1

	if input.Type != nil {
		setValues = append(setValues, fmt.Sprintf("type=$%d", argId))
		args = append(args, *input.Type)
		argId++
	}

	if input.Cost != nil {
		setValues = append(setValues, fmt.Sprintf("cost=$%d", argId))
		args = append(args, *input.Cost)
		argId++
	}

	if input.Name != nil {
		setValues = append(setValues, fmt.Sprintf("name=$%d", argId))
		args = append(args, *input.Name)
		argId++
	}

	if input.Image != nil {
		setValues = append(setValues, fmt.Sprintf("photo_id=$%d", argId))
		args = append(args, *input.Image)
		argId++
	}

	if input.CookingTime != nil {
		setValues = append(setValues, fmt.Sprintf("cooking_time=$%d", argId))
		args = append(args, *input.CookingTime)
		argId++
	}

	if input.Weight != nil {
		setValues = append(setValues, fmt.Sprintf("weight=$%d", argId))
		args = append(args, *input.Weight)
		argId++
	}

	if input.Description != nil {
		setValues = append(setValues, fmt.Sprintf("description=$%d", argId))
		args = append(args, *input.Description)
		argId++
	}

	if input.Status != nil {
		setValues = append(setValues, fmt.Sprintf("status=$%d", argId))
		args = append(args, *input.Status)
		argId++
	}

	setQuery := strings.Join(setValues, ", ")

	updateDishQuery := fmt.Sprintf("UPDATE dishes SET %s WHERE id = $%d", setQuery, argId)
	args = append(args, id)

	_, err := s.db.Exec(updateDishQuery, args...)
	if err != nil {
		log.Error().Err(err).Msg("")
	}

	return err
}

func (s *DishPostgres) GetAllDishes(id string) ([]domain.GetAllDishes, error) {
	var dishes []domain.GetAllDishes
	query := fmt.Sprintf("SELECT id, type, cost, name, image, weight, description, status FROM dishes WHERE restaurant_id = $1")
	err := s.db.Select(&dishes, query, id)
	if err != nil {
		log.Error().Err(err).Msg("")
	}
	fmt.Printf("%+v\n", dishes)
	return dishes, err
}

func (s *DishPostgres) DeleteDish(id string) error {
	query := fmt.Sprintf("DELETE FROM dishes WHERE id=$1")
	_, err := s.db.Exec(query, id)
	if err != nil {
		log.Error().Err(err).Msg("")
	}
	return err
}

func (s *DishPostgres) GetDishByID(id string) (domain.GetDishByID, error) {
	var dish domain.GetDishByID
	query := fmt.Sprintf(`SELECT type, cost, name, image, cooking_time, 
				weight, description, status FROM dishes WHERE id=$1`)
	err := s.db.Get(&dish, query, id)
	if err != nil {
		log.Error().Err(err).Msg("")
	}
	fmt.Printf("%+v\n", dish)
	return dish, err
}

func (s *DishPostgres) GetDishByRestaurantID(id string) ([]domain.GetAllDishes, error) {
	var dishes []domain.GetAllDishes
	query := fmt.Sprintf("SELECT id, type, cost, name, image, weight, description, status FROM dishes " +
		"WHERE restaurant_id = $1")
	err := s.db.Select(&dishes, query, &id)
	if err != nil {
		log.Error().Err(err).Msg("")
	}
	fmt.Printf("%+v\n", dishes)
	return dishes, err
}

func (s *DishPostgres) GetDishWithCategoryByRestaurantID(id string) ([]domain.GetDishesByRestaurant, error) {
	var dishesWithType []domain.GetDishesByRestaurant
	var types []domain.DishesCategory

	query := fmt.Sprintf("SELECT id, name FROM types")
	err := s.db.Select(&types, query)
	if err != nil {
		log.Error().Err(err).Msg("")
	}

	for _, v := range types {
		var buffDishes domain.GetDishesByRestaurant

		query := fmt.Sprintf("SELECT t1.id, t1.type, t1.cost, t1.name, t1.image, t1.weight, t1.description, " +
			"t1.status FROM dishes t1 INNER JOIN types t2 on t1.type = t2.id WHERE t2.name = $1 and t1.restaurant_id = $2")
		err = s.db.Select(&buffDishes.Dishes, query, v.Name, id)
		if err != nil {
			log.Error().Err(err).Msg("")
		}

		buffDishes.Type = v.Name
		buffDishes.TypeId = v.ID

		if buffDishes.Dishes != nil {
			dishesWithType = append(dishesWithType, buffDishes)
		}
	}

	return dishesWithType, err
}

func (s *DishPostgres) GetDishesTypes() ([]domain.DishesCategory, error) {
	var types []domain.DishesCategory
	query := fmt.Sprintf(`SELECT id, name FROM types`)
	err := s.db.Select(&types, query)
	if err != nil {
		log.Error().Err(err).Msg("")
	}
	fmt.Printf("%+v\n", types)
	return types, err
}
