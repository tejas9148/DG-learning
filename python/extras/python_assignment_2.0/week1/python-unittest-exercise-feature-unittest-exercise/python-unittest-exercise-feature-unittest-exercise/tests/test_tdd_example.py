
from src.tdd_example import TDDExample
tdd_example_instance = TDDExample()

def test_reverse_string():
    text = 'foobar'
    expected = 'raboof'

    actual = tdd_example_instance.reverse_string(text)

    assert expected == actual

def test_find_longest_word():
    sentence = '''
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    '''
    expected = 'consectetur'
    actual = tdd_example_instance.find_longest_word(sentence)

    assert expected == actual

def test_reverse_list():
    expected = [1, 2, 3, 4, 5]
    actual = tdd_example_instance.reverse_list([5, 4, 3, 2, 1])

    assert expected == actual

def test_count_digits():
    expected = 3

    actual = tdd_example_instance.count_digits([1, 1, 1, 2, 3], 1)

    assert expected == actual
