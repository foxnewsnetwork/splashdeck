require 'faker'
Factory.sequence :user do |n|
{ 
	:email => "testemail#{n}@faggot.com" ,
	:password => "password#{n}#{n}"
}
end # sequence

Factory.sequence :page do |n|
{ :title => Faker::Company.bs }
end # sequence

Factory.sequence :sticky do |n|
{
	:content => Faker::Company.bs ,
	:metadata => Faker::Company.bs ,
	:category => Faker::Company.bs ,
	:width => rand( 500 ) + 25,
	:height => rand( 500 ) + 25,
	:x => rand(100) ,
	:y => rand(100)
}
end # sticky
