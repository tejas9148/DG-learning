import boto3
from moto import mock_aws
from src.boto3_example import DynamodBExample
import pytest

@mock_aws
def test_create_dynamo_table():
    '''
        Implement the test logic here for testing create_dynamo_table method
    '''
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    obj = DynamodBExample()
    obj.create_movies_table()

    table = dynamodb.Table('Movies')

    assert table.table_name == 'Movies'



@mock_aws
def test_add_dynamo_record_table():
    '''
        Implement the test logic here for testing add_dynamo_record_table method
    '''
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    obj = DynamodBExample()
    obj.create_movies_table()

    item = {
        'year': 2020,
        'title': 'Test Movie'
    }

    obj.add_dynamo_record('Movies', item)

    table = dynamodb.Table('Movies')

    response = table.get_item(
        Key={
            'year': 2020,
            'title': 'Test Movie'
        }
    )

    assert response['Item'] == item

@mock_aws
def test_add_dynamo_record_table_failure():
    '''
        Implement the test logic here test_add_dynamo_record_table method for failures
    '''
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    obj = DynamodBExample()
    obj.create_movies_table()

    invalid_item = {
        'year': 'not-a-number',
        'title': 'Test Movie'
    }

    with pytest.raises(Exception):
        obj.add_dynamo_record('Movies', invalid_item)
