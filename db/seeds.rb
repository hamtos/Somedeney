# 管理者初期データ
Admin.create!(
  [
    {
      email: 'a@a',
      password: '999999',
    }
  ]
)

# 初期タグ管理用ユーザー
Customer.create!(
  [
    {
      email: 'a@a',
      password: '999999',
      name: 'shimada'
    }
  ]
)

# タグ初期値
[
  ['test1@test.com', 'テスト太郎', image: File.open('./app/assets/images/test.jpg')],
  ['test2@test.com', 'テスト徹子', image: File.open('./app/assets/images/test.jpg')]
].each do |category, name|
  User.create!(
    { customer_id: 1, tag_category: category, name: name, is_custom: false}
  )
end
