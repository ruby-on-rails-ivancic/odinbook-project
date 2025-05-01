require 'faker'

puts "🧼 Cleaning up database..."

Comment.destroy_all
Post.destroy_all
Friendship.destroy_all
User.destroy_all

Faker::UniqueGenerator.clear

puts "🌱 Seeding users..."

users = 10.times.map do
  User.create!(
    username: Faker::Internet.unique.username(specifier: 5..12),
    email: Faker::Internet.unique.email,
    password: "password",
    profile_photo: Faker::Avatar.image # or use ActiveStorage if you're attaching files
  )
end

puts "🔗 Creating friendships..."

users.each do |user|
  other_users = users - [ user ]
  friends_to_add = other_users.sample(3)

  friends_to_add.each do |friend|
    next if Friendship.exists?(requester: user, receiver: friend) || Friendship.exists?(requester: friend, receiver: user)

    # You might want to default new friendships as accepted
    Friendship.create!(
      requester: user,
      receiver: friend,
      status: 1
    )
  end
end

puts "📝 Creating posts and comments..."

users.each do |user|
  3.times do
    post = user.posts.create!(
      content: Faker::Lorem.paragraph(sentence_count: 2)
    )

    commenters = users.sample(5)
    commenters.each do |commenter|
      post.comments.create!(
        user: commenter,
        content: Faker::Lorem.sentence
      )
    end
  end
end

puts "✅ Done seeding!"

User.create!(
  username: "demo",
  email: "demo@example.com",
  password: "password",
  password_confirmation: "password"
)
puts "🧪 Created demo user: demo@example.com / password"
