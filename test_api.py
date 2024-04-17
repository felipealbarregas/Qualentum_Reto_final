import unittest
from app import app, db, Data

class TestAPI(unittest.TestCase):
    def setUp(self):
        # Define la IP de la API aquí
        self.api_ip = "192.168.0.11"
        self.api_port = 80

    def tearDown(self):
        db.session.remove()
        db.drop_all()

    def test_insert_data(self):
        # Prueba de inserción exitosa
        response = self.app.post('/data', json={"name": "Test"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['message'], 'Data inserted successfully')

        # Prueba de inserción fallida debido a datos duplicados
        response = self.app.post('/data', json={"name": "Test"})
        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json['message'], 'Data already exists')

    def test_get_all_data(self):
        # Prueba de obtener todos los datos
        db.session.add(Data(name="Test"))
        db.session.add(Data(name="Test2"))
        db.session.commit()
        response = self.app.get('/data')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json), 2)

    def test_delete_data(self):
        # Prueba de eliminación exitosa
        db.session.add(Data(name="Test"))
        db.session.commit()
        response = self.app.delete('/data/1')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['message'], 'Data deleted successfully')

        # Prueba de eliminación de datos no existentes
        response = self.app.delete('/data/2')
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json['message'], 'Data not found')

if __name__ == '__main__':
    unittest.main()
