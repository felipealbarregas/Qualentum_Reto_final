import unittest
from flask import Flask
from flask_testing import TestCase
from app import db  # Importa la base de datos
from app.models import Data
from app.routes import data_routes

class TestApp(TestCase):

    def create_app(self):
        # Crea la aplicación Flask
        app = Flask(__name__)
    
        # Configura la aplicación Flask para pruebas
        app.config['TESTING'] = True
    
        # Inicializa la base de datos
        db.init_app(app)

        # Registra blueprints/routes
        app.register_blueprint(data_routes)

        return app

    def test_insert_data(self):
        # Prueba insertar datos válidos
        response = self.client.post('/data', json={'name': 'Test Data'})
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Data inserted successfully', response.data)

        # Prueba insertar datos que ya existen
        response = self.client.post('/data', json={'name': 'Test Data'})
        self.assertEqual(response.status_code, 409)
        self.assertIn(b'Data already exists', response.data)

    def test_get_all_data(self):
        # Prueba obtener todos los datos
        data = Data(name='Test Data')
        db.session.add(data)
        db.session.commit()
        response = self.client.get('/data')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Test Data', response.data)

    def test_delete_data(self):
        # Inserta un dato para luego eliminarlo
        data = Data(name='Test Data')
        db.session.add(data)
        db.session.commit()
        data_id = data.id

        # Prueba eliminar un dato existente
        response = self.client.delete(f'/data/{data_id}')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Data deleted successfully', response.data)

        # Prueba eliminar un dato que no existe
        response = self.client.delete('/data/123')
        self.assertEqual(response.status_code, 404)
        self.assertIn(b'Data not found', response.data)

if __name__ == '__main__':
    unittest.main()
