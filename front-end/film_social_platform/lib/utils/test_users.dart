// Test kullanıcıları - Flutter uygulamasında referans için
class TestUsers {
  static const List<Map<String, String>> users = [
    {
      'email': 'test1@example.com',
      'password': 'password123',
      'username': 'testuser1',
      'country': 'Turkey',
    },
    {
      'email': 'test2@example.com',
      'password': 'password123',
      'username': 'testuser2',
      'country': 'USA',
    },
    {
      'email': 'admin@example.com',
      'password': 'admin123',
      'username': 'admin',
      'country': 'Turkey',
    },
  ];

  static String getTestUserInfo() {
    return '''
Test Kullanıcıları:

1. Email: test1@example.com
   Şifre: password123
   Kullanıcı Adı: testuser1
   Ülke: Turkey

2. Email: test2@example.com
   Şifre: password123
   Kullanıcı Adı: testuser2
   Ülke: USA

3. Email: admin@example.com
   Şifre: admin123
   Kullanıcı Adı: admin
   Ülke: Turkey
''';
  }
}

