from src.general_example import GeneralExample
from unittest.mock import patch


def test_flatten_dictionary():
    content = {
        'key1': [3, 2, 1],
        'key2': [42, 55, 10],
        'key3': [0, 22]
    }

    expected = [0, 1, 2, 3, 10, 22, 42, 55]

    actual = GeneralExample.flatten_dictionary(content)

    assert actual == expected


def test_load_employee_rec_from_database():
    obj = GeneralExample()

    actual = obj.load_employee_rec_from_database()

    expected = ['emp001', 'Sam', '100000']

    assert actual == expected


@patch('src.general_example.GeneralExample.load_employee_rec_from_database')
def test_fetch_emp_details(mock_load):
    mock_load.return_value = ['emp001', 'Sam', '100000']

    obj = GeneralExample()

    actual = obj.fetch_emp_details()

    expected = {
        'empId': 'emp001',
        'empName': 'Sam',
        'empSalary': '100000'
    }

    assert actual == expected