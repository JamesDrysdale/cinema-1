require_relative("../db/sql_runner")

class Customer

    attr_accessor :name, :funds
    attr_reader :id

    def initialize(options)
        @id = options["id"].to_i if options["id"]
        @name = options["name"]
        @funds = options["funds"].to_f
    end

    # (C)reate
    def save()
        sql = "INSERT INTO customers (name, funds) VALUES ($1, $2) RETURNING id;"
        values = [@name, @funds]
        @id = SqlRunner.run(sql, values)[0]["id"].to_i
    end

    # (R)ead
    def self.all()
        customers_array = SqlRunner.run("SELECT * FROM customers;")
        return Customer.map_to_objects(customers_array)
    end

    # (U)pdate
    def update()
        sql = "UPDATE customers SET (name, funds) = ($1, $2) WHERE id = $3;"
        values = [@name, @funds, @id]
        SqlRunner.run(sql, values)
    end

    # (D)elete
    def delete()
        sql = "DELETE FROM customers WHERE id = $1;"
        values = [@id]
        SqlRunner.run(sql, values)
    end

    def films()
        sql = "SELECT films.* FROM films
        INNER JOIN tickets
        ON films.id = tickets.film_id
        WHERE tickets.customer_id = $1;"
        values = [@id]
        films_array = SqlRunner.run(sql, values)
        return Film.map_to_objects(films_array)
    end

    def buy_ticket(film)
        return if @funds < film.price
        @funds -= film.price
        update()
        ticket = Ticket.new({"customer_id" => @id, "film_id" => film.id})
        ticket.save()
    end

    def self.map_to_objects(customers_array)
        return customers_array.map {|customer_hash| Customer.new(customer_hash)}
    end

    def self.delete_all()
        SqlRunner.run("DELETE FROM customers;")
    end

end