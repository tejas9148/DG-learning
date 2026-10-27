"""Maps the country names used in the survey to a continent."""

CONTINENTS = {
    "Africa": [
        "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Cameroon",
        "Cape Verde", "Central African Republic", "Chad", "Comoros", "Congo, Republic of the",
        "Democratic Republic of the Congo", "Côte d'Ivoire", "Djibouti", "Egypt",
        "Equatorial Guinea", "Eritrea", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea",
        "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Madagascar",
        "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger",
        "Nigeria", "Rwanda", "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone",
        "Somalia", "South Africa", "South Sudan", "Sudan", "Swaziland", "Togo", "Tunisia",
        "Uganda", "United Republic of Tanzania", "Zambia", "Zimbabwe",
    ],
    "Asia": [
        "Afghanistan", "Armenia", "Azerbaijan", "Bahrain", "Bangladesh", "Bhutan",
        "Brunei Darussalam", "Cambodia", "China", "Democratic People's Republic of Korea", "North Korea",
        "Georgia", "Hong Kong (S.A.R.)", "India", "Indonesia", "Iran", "Iran, Islamic Republic of",
        "Iraq", "Israel", "Japan", "Jordan", "Kazakhstan", "Kuwait", "Kyrgyzstan",
        "Lao People's Democratic Republic", "Lebanon", "Malaysia", "Maldives", "Mongolia",
        "Myanmar", "Nepal", "Oman", "Pakistan", "Palestine", "Philippines", "Qatar",
        "Republic of Korea", "Saudi Arabia", "Singapore", "South Korea", "Sri Lanka",
        "Syrian Arab Republic", "Taiwan", "Tajikistan", "Thailand", "Timor-Leste", "Turkey",
        "Turkmenistan", "United Arab Emirates", "Uzbekistan", "Viet Nam", "Yemen",
    ],
    "Europe": [
        "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina",
        "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland",
        "France", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Isle of Man", "Italy",
        "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Malta", "Monaco",
        "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Moldova",
        "Romania", "Russian Federation", "San Marino", "Serbia", "Slovakia", "Slovenia",
        "Spain", "Sweden", "Switzerland", "The former Yugoslav Republic of Macedonia",
        "Ukraine", "United Kingdom", "Vatican City",
    ],
    "North America": [
        "Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Canada", "Costa Rica", "Cuba",
        "Dominica", "Dominican Republic", "El Salvador", "Grenada", "Guatemala", "Haiti",
        "Honduras", "Jamaica", "Mexico", "Nicaragua", "Panama", "Saint Kitts and Nevis",
        "Saint Lucia", "Saint Vincent and the Grenadines", "Trinidad and Tobago",
        "United States",
    ],
    "South America": [
        "Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay",
        "Peru", "Suriname", "Uruguay", "Venezuela, Bolivarian Republic of",
    ],
    "Oceania": [
        "Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia, Federated States of",
        "Nauru", "New Zealand", "Palau", "Papua New Guinea", "Samoa", "Solomon Islands",
        "Tonga", "Tuvalu", "Vanuatu",
    ],
}

# flip it so we can look up a country directly
COUNTRY_TO_CONTINENT = {
    country.lower(): continent
    for continent, countries in CONTINENTS.items()
    for country in countries
}


def get_continent(country):
    """Returns the continent for a country name, or 'Unknown' (e.g. 'Nomadic')."""
    if not isinstance(country, str):
        return "Unknown"
    name = country.strip().rstrip(".").lower()   # some names end with "..."
    return COUNTRY_TO_CONTINENT.get(name, "Unknown")
