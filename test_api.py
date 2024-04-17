# -*- coding: utf-8 -*-
import unittest
import requests


class TestAPI(unittest.TestCase):
    def setUp(self):
        # Define la IP de la API aquí
        self.api_address = "http://192.168.0.11:80"
        self.data_list = None

    def tearDown(self):
        pass  # No necesitamos realizar acciones específicas al finalizar cada prueba

    def test_insert_data(self):
        # Prueba de inserción exitosa
        response = requests.post(f"{self.api_address}/data", json={"name": "Test"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['message'], 'Data inserted successfully')

        # Prueba de inserción fallida debido a datos duplicados
        response = requests.post(f"{self.api_address}/data", json={"name": "Test"})
        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['message'], 'Data already exists')

    def test_get_all_data(self):
        # Prueba de obtener todos los datos
        response = requests.get(f"{self.api_address}/data")
        self.assertEqual(response.status_code, 200)
        self.data_list = response.json()
        self.assertIsInstance(self.data_list, list)

    def test_delete_data(self):
        # Asegúrate de que test_get_all_data se haya ejecutado antes
        self.assertIsNotNone(self.data_list)
        self.test_get_all_data()  # Llama al método para asegurarte de que self.data_list esté inicializado

        # Prueba de eliminación exitosa
        data_id = self.data_list[0]['id']
        response = requests.delete(f"{self.api_address}/data/{data_id}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['message'], 'Data deleted successfully')

        # Prueba de eliminación de datos no existentes
        response = requests.delete(f"{self.api_address}/data/5")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json()['message'], 'Data not found')

if __name__ == '__main__':
    unittest.main()
