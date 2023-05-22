# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(name: 'David', username: 'david', email: 'david@devtester.com', password: 'asdasd', rol:1)
User.create(name: 'alexa', username: 'alexa', email: 'alexa@iapg.com', password: 'ASas123', rol:1)