# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Countries
Country.where(name: "Afghanistan").first_or_create(code: "AF", id: 2)
Country.where(name: "Aland Islands").first_or_create(code: "AX", id: 3)
Country.where(name: "Albania").first_or_create(code: "AL", id: 4)
Country.where(name: "Algeria").first_or_create(code: "DZ", id: 5)
Country.where(name: "American Samoa").first_or_create(code: "AS", id: 6)
Country.where(name: "Andorra").first_or_create(code: "AD", id: 7)
Country.where(name: "Angola").first_or_create(code: "AO", id: 8)
Country.where(name: "Anguilla").first_or_create(code: "AI", id: 9)
Country.where(name: "Antarctica").first_or_create(code: "AQ", id: 10)
Country.where(name: "Antigua And Barbuda").first_or_create(code: "AG", id: 11)
Country.where(name: "Argentina").first_or_create(code: "AR", id: 12)
Country.where(name: "Armenia").first_or_create(code: "AM", id: 13)
Country.where(name: "Aruba").first_or_create(code: "AW", id: 14)
Country.where(name: "Australia").first_or_create(code: "AU", id: 15)
Country.where(name: "Austria").first_or_create(code: "AT", id: 16)
Country.where(name: "Azerbaijan").first_or_create(code: "AZ", id: 17)
Country.where(name: "Bahamas").first_or_create(code: "BS", id: 18)
Country.where(name: "Bahrain").first_or_create(code: "BH", id: 19)
Country.where(name: "Bangladesh").first_or_create(code: "BD", id: 20)
Country.where(name: "Barbados").first_or_create(code: "BB", id: 21)
Country.where(name: "Belarus").first_or_create(code: "BY", id: 22)
Country.where(name: "Belgium").first_or_create(code: "BE", id: 23)
Country.where(name: "Belize").first_or_create(code: "BZ", id: 24)
Country.where(name: "Benin").first_or_create(code: "BJ", id: 25)
Country.where(name: "Bermuda").first_or_create(code: "BM", id: 26)
Country.where(name: "Bolivia").first_or_create(code: "BO", id: 27)
Country.where(name: "Bonaire").first_or_create(code: "BQ", id: 28)
Country.where(name: "Bosnia And Herzegovina").first_or_create(code: "BA", id: 29)
Country.where(name: "Botswana").first_or_create(code: "BW", id: 30)
Country.where(name: "Bouvet Island").first_or_create(code: "BV", id: 31)
Country.where(name: "Brazil").first_or_create(code: "BR", id: 32)
Country.where(name: "British Indian Ocean Territory").first_or_create(code: "IO", id: 33)
Country.where(name: "Brunei Darussalam").first_or_create(code: "BN", id: 34)
Country.where(name: "Bulgaria").first_or_create(code: "BG", id: 35)
Country.where(name: "Burkina Faso").first_or_create(code: "BF", id: 36)
Country.where(name: "Burundi").first_or_create(code: "BI", id: 37)
Country.where(name: "Cambodia").first_or_create(code: "KH", id: 38)
Country.where(name: "Cameroon").first_or_create(code: "CM", id: 39)
Country.where(name: "Canada").first_or_create(code: "CA", id: 40, subunit: "Province or Territory")
Country.where(name: "Cape Verde").first_or_create(code: "CV", id: 41)
Country.where(name: "Cayman Islands").first_or_create(code: "KY", id: 42)
Country.where(name: "Central African Republic").first_or_create(code: "CF", id: 43)
Country.where(name: "Chad").first_or_create(code: "TD", id: 44)
Country.where(name: "Chile").first_or_create(code: "CL", id: 45)
Country.where(name: "China").first_or_create(code: "CN", id: 46)
Country.where(name: "Christmas Island").first_or_create(code: "CX", id: 47)
Country.where(name: "Cocos (Keeling) Islands").first_or_create(code: "CC", id: 48)
Country.where(name: "Colombia").first_or_create(code: "CO", id: 49)
Country.where(name: "Comoros").first_or_create(code: "KM", id: 50)
Country.where(name: "Congo").first_or_create(code: "CG", id: 51)
Country.where(name: "Congo, Democratic Republic").first_or_create(code: "CD", id: 52)
Country.where(name: "Cook Islands").first_or_create(code: "CK", id: 53)
Country.where(name: "Costa Rica").first_or_create(code: "CR", id: 54)
Country.where(name: "Cote d'Ivoire").first_or_create(code: "CI", id: 55)
Country.where(name: "Croatia").first_or_create(code: "HR", id: 56)
Country.where(name: "Cuba").first_or_create(code: "CU", id: 57)
Country.where(name: "Curacao").first_or_create(code: "CW", id: 58)
Country.where(name: "Cyprus").first_or_create(code: "CY", id: 59)
Country.where(name: "Czech Republic").first_or_create(code: "CZ", id: 60)
Country.where(name: "Denmark").first_or_create(code: "DK", id: 61)
Country.where(name: "Djibouti").first_or_create(code: "DJ", id: 62)
Country.where(name: "Dominica").first_or_create(code: "DM", id: 63)
Country.where(name: "Dominican Republic").first_or_create(code: "DO", id: 64)
Country.where(name: "Ecuador").first_or_create(code: "EC", id: 65)
Country.where(name: "Egypt").first_or_create(code: "EG", id: 66)
Country.where(name: "El Salvador").first_or_create(code: "SV", id: 67)
Country.where(name: "Equatorial Guinea").first_or_create(code: "GQ", id: 68)
Country.where(name: "Eritrea").first_or_create(code: "ER", id: 69)
Country.where(name: "Estonia").first_or_create(code: "EE", id: 70)
Country.where(name: "Ethiopia").first_or_create(code: "ET", id: 71)
Country.where(name: "Falkland Islands (Malvinas)").first_or_create(code: "FK", id: 72)
Country.where(name: "Faroe Islands").first_or_create(code: "FO", id: 73)
Country.where(name: "Fiji").first_or_create(code: "FJ", id: 74)
Country.where(name: "Finland").first_or_create(code: "FI", id: 75)
Country.where(name: "France").first_or_create(code: "FR", id: 76)
Country.where(name: "French Guiana").first_or_create(code: "GF", id: 77)
Country.where(name: "French Polynesia").first_or_create(code: "PF", id: 78)
Country.where(name: "French Southern Territories").first_or_create(code: "TF", id: 79)
Country.where(name: "Gabon").first_or_create(code: "GA", id: 80)
Country.where(name: "Gambia").first_or_create(code: "GM", id: 81)
Country.where(name: "Georgia").first_or_create(code: "GE", id: 82)
Country.where(name: "Germany").first_or_create(code: "DE", id: 83)
Country.where(name: "Ghana").first_or_create(code: "GH", id: 84)
Country.where(name: "Gibraltar").first_or_create(code: "GI", id: 85)
Country.where(name: "Greece").first_or_create(code: "GR", id: 86)
Country.where(name: "Greenland").first_or_create(code: "GL", id: 87)
Country.where(name: "Grenada").first_or_create(code: "GD", id: 88)
Country.where(name: "Guadeloupe").first_or_create(code: "GP", id: 89)
Country.where(name: "Guam").first_or_create(code: "GU", id: 90)
Country.where(name: "Guatemala").first_or_create(code: "GT", id: 91)
Country.where(name: "Guernsey").first_or_create(code: "GG", id: 92)
Country.where(name: "Guinea").first_or_create(code: "GN", id: 93)
Country.where(name: "Guinea-Bissau").first_or_create(code: "GW", id: 94)
Country.where(name: "Guyana").first_or_create(code: "GY", id: 95)
Country.where(name: "Haiti").first_or_create(code: "HT", id: 96)
Country.where(name: "Heard Island And Mcdonald Islands").first_or_create(code: "HM", id: 97)
Country.where(name: "Holy See (Vatican City State)").first_or_create(code: "VA", id: 98)
Country.where(name: "Honduras").first_or_create(code: "HN", id: 99)
Country.where(name: "Hong Kong").first_or_create(code: "HK", id: 100)
Country.where(name: "Hungary").first_or_create(code: "HU", id: 101)
Country.where(name: "Iceland").first_or_create(code: "IS", id: 102)
Country.where(name: "India").first_or_create(code: "IN", id: 103)
Country.where(name: "Indonesia").first_or_create(code: "ID", id: 104)
Country.where(name: "Iran").first_or_create(code: "IR", id: 105)
Country.where(name: "Iraq").first_or_create(code: "IQ", id: 106)
Country.where(name: "Ireland").first_or_create(code: "IE", id: 107)
Country.where(name: "Isle Of Man").first_or_create(code: "IM", id: 108)
Country.where(name: "Israel").first_or_create(code: "IL", id: 109)
Country.where(name: "Italy").first_or_create(code: "IT", id: 110)
Country.where(name: "Jamaica").first_or_create(code: "JM", id: 111)
Country.where(name: "Japan").first_or_create(code: "JP", id: 112)
Country.where(name: "Jersey").first_or_create(code: "JE", id: 113)
Country.where(name: "Jordan").first_or_create(code: "JO", id: 114)
Country.where(name: "Kazakhstan").first_or_create(code: "KZ", id: 115)
Country.where(name: "Kenya").first_or_create(code: "KE", id: 116)
Country.where(name: "Kiribati").first_or_create(code: "KI", id: 117)
Country.where(name: "Korea, North").first_or_create(code: "KP", id: 118)
Country.where(name: "Korea, South").first_or_create(code: "KR", id: 119)
Country.where(name: "Kuwait").first_or_create(code: "KW", id: 120)
Country.where(name: "Kyrgyzstan").first_or_create(code: "KG", id: 121)
Country.where(name: "Lao ").first_or_create(code: "LA", id: 122)
Country.where(name: "Latvia").first_or_create(code: "LV", id: 123)
Country.where(name: "Lebanon").first_or_create(code: "LB", id: 124)
Country.where(name: "Lesotho").first_or_create(code: "LS", id: 125)
Country.where(name: "Liberia").first_or_create(code: "LR", id: 126)
Country.where(name: "Libya").first_or_create(code: "LY", id: 127)
Country.where(name: "Liechtenstein").first_or_create(code: "LI", id: 128)
Country.where(name: "Lithuania").first_or_create(code: "LT", id: 129)
Country.where(name: "Luxembourg").first_or_create(code: "LU", id: 130)
Country.where(name: "Macao").first_or_create(code: "MO", id: 131)
Country.where(name: "Macedonia").first_or_create(code: "MK", id: 132)
Country.where(name: "Madagascar").first_or_create(code: "MG", id: 133)
Country.where(name: "Malawi").first_or_create(code: "MW", id: 134)
Country.where(name: "Malaysia").first_or_create(code: "MY", id: 135)
Country.where(name: "Maldives").first_or_create(code: "MV", id: 136)
Country.where(name: "Mali").first_or_create(code: "ML", id: 137)
Country.where(name: "Malta").first_or_create(code: "MT", id: 138)
Country.where(name: "Marshall Islands").first_or_create(code: "MH", id: 139)
Country.where(name: "Martinique").first_or_create(code: "MQ", id: 140)
Country.where(name: "Mauritania").first_or_create(code: "MR", id: 141)
Country.where(name: "Mauritius").first_or_create(code: "MU", id: 142)
Country.where(name: "Mayotte").first_or_create(code: "YT", id: 143)
Country.where(name: "Mexico").first_or_create(code: "MX", id: 144)
Country.where(name: "Micronesia").first_or_create(code: "FM", id: 145)
Country.where(name: "Moldova").first_or_create(code: "MD", id: 146)
Country.where(name: "Monaco").first_or_create(code: "MC", id: 147)
Country.where(name: "Mongolia").first_or_create(code: "MN", id: 148)
Country.where(name: "Montenegro").first_or_create(code: "ME", id: 149)
Country.where(name: "Montserrat").first_or_create(code: "MS", id: 150)
Country.where(name: "Morocco").first_or_create(code: "MA", id: 151)
Country.where(name: "Mozambique").first_or_create(code: "MZ", id: 152)
Country.where(name: "Myanmar").first_or_create(code: "MM", id: 153)
Country.where(name: "Namibia").first_or_create(code: "NA", id: 154)
Country.where(name: "Nauru").first_or_create(code: "NR", id: 155)
Country.where(name: "Nepal").first_or_create(code: "NP", id: 156)
Country.where(name: "Netherlands").first_or_create(code: "NL", id: 157)
Country.where(name: "New Caledonia").first_or_create(code: "NC", id: 158)
Country.where(name: "New Zealand").first_or_create(code: "NZ", id: 159)
Country.where(name: "Nicaragua").first_or_create(code: "NI", id: 160)
Country.where(name: "Niger").first_or_create(code: "NE", id: 161)
Country.where(name: "Nigeria").first_or_create(code: "NG", id: 162)
Country.where(name: "Niue").first_or_create(code: "NU", id: 163)
Country.where(name: "Norfolk Island").first_or_create(code: "NF", id: 164)
Country.where(name: "Northern Mariana Islands").first_or_create(code: "MP", id: 165)
Country.where(name: "Norway").first_or_create(code: "NO", id: 166)
Country.where(name: "Oman").first_or_create(code: "OM", id: 167)
Country.where(name: "Pakistan").first_or_create(code: "PK", id: 168)
Country.where(name: "Palau").first_or_create(code: "PW", id: 169)
Country.where(name: "Palestine").first_or_create(code: "PS", id: 170)
Country.where(name: "Panama").first_or_create(code: "PA", id: 171)
Country.where(name: "Papua New Guinea").first_or_create(code: "PG", id: 172)
Country.where(name: "Paraguay").first_or_create(code: "PY", id: 173)
Country.where(name: "Peru").first_or_create(code: "PE", id: 174)
Country.where(name: "Philippines").first_or_create(code: "PH", id: 175)
Country.where(name: "Pitcairn").first_or_create(code: "PN", id: 176)
Country.where(name: "Poland").first_or_create(code: "PL", id: 177)
Country.where(name: "Portugal").first_or_create(code: "PT", id: 178)
Country.where(name: "Puerto Rico").first_or_create(code: "PR", id: 179)
Country.where(name: "Qatar").first_or_create(code: "QA", id: 180)
Country.where(name: "Reunion").first_or_create(code: "RE", id: 181)
Country.where(name: "Romania").first_or_create(code: "RO", id: 182)
Country.where(name: "Russian Federation").first_or_create(code: "RU", id: 183)
Country.where(name: "Rwanda").first_or_create(code: "RW", id: 184)
Country.where(name: "Saint Bartholemy").first_or_create(code: "BL", id: 185)
Country.where(name: "Saint Helena").first_or_create(code: "SH", id: 186)
Country.where(name: "Saint Kitts And Nevis").first_or_create(code: "KN", id: 187)
Country.where(name: "Saint Lucia").first_or_create(code: "LC", id: 188)
Country.where(name: "Saint Martin (French Part)").first_or_create(code: "MF", id: 189)
Country.where(name: "Saint Pierre And Miquelon").first_or_create(code: "PM", id: 190)
Country.where(name: "Saint Vincent And The Grenadines").first_or_create(code: "VC", id: 191)
Country.where(name: "Samoa").first_or_create(code: "WS", id: 192)
Country.where(name: "San Marino").first_or_create(code: "SM", id: 193)
Country.where(name: "Sao Tome And Principe").first_or_create(code: "ST", id: 194)
Country.where(name: "Saudi Arabia").first_or_create(code: "SA", id: 195)
Country.where(name: "Senegal").first_or_create(code: "SN", id: 196)
Country.where(name: "Serbia").first_or_create(code: "RS", id: 197)
Country.where(name: "Seychelles").first_or_create(code: "SC", id: 198)
Country.where(name: "Sierra Leone").first_or_create(code: "SL", id: 199)
Country.where(name: "Singapore").first_or_create(code: "SG", id: 200)
Country.where(name: "Sint Maarten (Dutch Part)").first_or_create(code: "SX", id: 201)
Country.where(name: "Slovakia").first_or_create(code: "SK", id: 202)
Country.where(name: "Slovenia").first_or_create(code: "SI", id: 203)
Country.where(name: "Solomon Islands").first_or_create(code: "SB", id: 204)
Country.where(name: "Somalia").first_or_create(code: "SO", id: 205)
Country.where(name: "South Africa").first_or_create(code: "ZA", id: 206)
Country.where(name: "South Georgia / South Sandwich Islands").first_or_create(code: "GS", id: 207)
Country.where(name: "Spain").first_or_create(code: "ES", id: 208)
Country.where(name: "Sri Lanka").first_or_create(code: "LK", id: 209)
Country.where(name: "Sudan").first_or_create(code: "SD", id: 210)
Country.where(name: "Suriname").first_or_create(code: "SR", id: 211)
Country.where(name: "Svalbard And Jan Mayen").first_or_create(code: "SJ", id: 212)
Country.where(name: "Swaziland").first_or_create(code: "SZ", id: 213)
Country.where(name: "Sweden").first_or_create(code: "SE", id: 214)
Country.where(name: "Switzerland").first_or_create(code: "CH", id: 215)
Country.where(name: "Syrian Arab Republic").first_or_create(code: "SY", id: 216)
Country.where(name: "Taiwan").first_or_create(code: "TW", id: 217)
Country.where(name: "Tajikistan").first_or_create(code: "TJ", id: 218)
Country.where(name: "Tanzania").first_or_create(code: "TZ", id: 219)
Country.where(name: "Thailand").first_or_create(code: "TH", id: 220)
Country.where(name: "Timor-Leste").first_or_create(code: "TL", id: 221)
Country.where(name: "Togo").first_or_create(code: "TG", id: 222)
Country.where(name: "Tokelau").first_or_create(code: "TK", id: 223)
Country.where(name: "Tonga").first_or_create(code: "TO", id: 224)
Country.where(name: "Trinidad And Tobago").first_or_create(code: "TT", id: 225)
Country.where(name: "Tunisia").first_or_create(code: "TN", id: 226)
Country.where(name: "Turkey").first_or_create(code: "TR", id: 227)
Country.where(name: "Turkmenistan").first_or_create(code: "TM", id: 228)
Country.where(name: "Turks And Caicos Islands").first_or_create(code: "TC", id: 229)
Country.where(name: "Tuvalu").first_or_create(code: "TV", id: 230)
Country.where(name: "Uganda").first_or_create(code: "UG", id: 231)
Country.where(name: "Ukraine").first_or_create(code: "UA", id: 232)
Country.where(name: "United Arab Emirates").first_or_create(code: "AE", id: 233)
Country.where(name: "United Kingdom").first_or_create(code: "GB", id: 234)
Country.where(name: "United States").first_or_create(code: "US", id: 235, subunit: "State")
Country.where(name: "United States Minor Outlying Islands").first_or_create(code: "UM", id: 236)
Country.where(name: "Uruguay").first_or_create(code: "UY", id: 237)
Country.where(name: "Uzbekistan").first_or_create(code: "UZ", id: 238)
Country.where(name: "Vanuatu").first_or_create(code: "VU", id: 239)
Country.where(name: "Venezuela").first_or_create(code: "VE", id: 240)
Country.where(name: "Viet Nam").first_or_create(code: "VN", id: 241)
Country.where(name: "Virgin Islands, British").first_or_create(code: "VG", id: 242)
Country.where(name: "Virgin Islands, U.S.").first_or_create(code: "VI", id: 243)
Country.where(name: "Wallis And Futuna").first_or_create(code: "WF", id: 244)
Country.where(name: "Western Sahara").first_or_create(code: "EH", id: 245)
Country.where(name: "Yemen").first_or_create(code: "YE", id: 246)
Country.where(name: "Zambia").first_or_create(code: "ZM", id: 247)
Country.where(name: "Zimbabwe").first_or_create(code: "ZW", id: 248)
Country.where(name: "England").first_or_create(id: 249)
Country.where(name: "Scotland").first_or_create(id: 250)
Country.where(name: "None").first_or_create(id: 999_999)
Country.where(name: "UNKNOWN").first_or_create(id: 1_000_000)

united_states = Country.where(name: "United States").first_or_create(code: "US")

# States

State.where(name: "Alabama").first_or_create(id: 1, country_id: 235, code: "AL")
State.where(name: "Alaska").first_or_create(id: 2, country_id: 235, code: "AK")
State.where(name: "Arizona").first_or_create(id: 3, country_id: 235, code: "AZ")
State.where(name: "Arkansas").first_or_create(id: 4, country_id: 235, code: "AR")
State.where(name: "California").first_or_create(id: 5, country_id: 235, code: "CA")
State.where(name: "Colorado").first_or_create(id: 6, country_id: 235, code: "CO")
State.where(name: "Connecticut").first_or_create(id: 7, country_id: 235, code: "CT")
State.where(name: "Delaware").first_or_create(id: 8, country_id: 235, code: "DE")
State.where(name: "District of Columbia").first_or_create(id: 9, country_id: 235, code: "DC")
State.where(name: "Florida").first_or_create(id: 10, country_id: 235, code: "FL")
State.where(name: "Georgia").first_or_create(id: 11, country_id: 235, code: "GA")
State.where(name: "Hawaii").first_or_create(id: 12, country_id: 235, code: "HI")
State.where(name: "Idaho").first_or_create(id: 13, country_id: 235, code: "ID")
State.where(name: "Illinois").first_or_create(id: 14, country_id: 235, code: "IL")
State.where(name: "Indiana").first_or_create(id: 15, country_id: 235, code: "IN")
State.where(name: "Iowa").first_or_create(id: 16, country_id: 235, code: "IA")
State.where(name: "Kansas").first_or_create(id: 17, country_id: 235, code: "KS")
State.where(name: "Kentucky").first_or_create(id: 18, country_id: 235, code: "KY")
State.where(name: "Louisiana").first_or_create(id: 19, country_id: 235, code: "LA")
State.where(name: "Maine").first_or_create(id: 20, country_id: 235, code: "ME")
State.where(name: "Maryland").first_or_create(id: 21, country_id: 235, code: "MD")
State.where(name: "Massachusetts").first_or_create(id: 22, country_id: 235, code: "MA")
State.where(name: "Michigan").first_or_create(id: 23, country_id: 235, code: "MI")
State.where(name: "Minnesota").first_or_create(id: 24, country_id: 235, code: "MN")
State.where(name: "Mississippi").first_or_create(id: 25, country_id: 235, code: "MS")
State.where(name: "Missouri").first_or_create(id: 26, country_id: 235, code: "MO")
State.where(name: "Montana").first_or_create(id: 27, country_id: 235, code: "MT")
State.where(name: "Nebraska").first_or_create(id: 28, country_id: 235, code: "NE")
State.where(name: "Nevada").first_or_create(id: 29, country_id: 235, code: "NV")
State.where(name: "New Hampshire").first_or_create(id: 30, country_id: 235, code: "NH")
State.where(name: "New Jersey").first_or_create(id: 31, country_id: 235, code: "NJ")
State.where(name: "New Mexico").first_or_create(id: 32, country_id: 235, code: "NM")
State.where(name: "New York").first_or_create(id: 33, country_id: 235, code: "NY")
State.where(name: "North Carolina").first_or_create(id: 34, country_id: 235, code: "NC")
State.where(name: "North Dakota").first_or_create(id: 35, country_id: 235, code: "ND")
State.where(name: "Ohio").first_or_create(id: 36, country_id: 235, code: "OH")
State.where(name: "Oklahoma").first_or_create(id: 37, country_id: 235, code: "OK")
State.where(name: "Oregon").first_or_create(id: 38, country_id: 235, code: "OR")
State.where(name: "Pennsylvania").first_or_create(id: 39, country_id: 235, code: "PA")
State.where(name: "Rhode Island").first_or_create(id: 40, country_id: 235, code: "RI")
State.where(name: "South Carolina").first_or_create(id: 41, country_id: 235, code: "SC")
State.where(name: "South Dakota").first_or_create(id: 42, country_id: 235, code: "SD")
State.where(name: "Tennessee").first_or_create(id: 43, country_id: 235, code: "TN")
State.where(name: "Texas").first_or_create(id: 44, country_id: 235, code: "TX")
State.where(name: "Utah").first_or_create(id: 45, country_id: 235, code: "UT")
State.where(name: "Vermont").first_or_create(id: 46, country_id: 235, code: "VT")
State.where(name: "Virginia").first_or_create(id: 47, country_id: 235, code: "VA")
State.where(name: "Washington").first_or_create(id: 48, country_id: 235, code: "WA")
State.where(name: "West Virginia").first_or_create(id: 49, country_id: 235, code: "WV")
State.where(name: "Wisconsin").first_or_create(id: 50, country_id: 235, code: "WI")
State.where(name: "Wyoming").first_or_create(id: 51, country_id: 235, code: "WY")
State.where(name: "Ontario").first_or_create(id: 52, country_id: 40, code: "ON")
State.where(name: "Quebec").first_or_create(id: 53, country_id: 40, code: "QC")
State.where(name: "Nova Scotia").first_or_create(id: 54, country_id: 40, code: "NS")
State.where(name: "New Brunswick").first_or_create(id: 55, country_id: 40, code: "NB")
State.where(name: "Manitoba").first_or_create(id: 56, country_id: 40, code: "MB")
State.where(name: "British Columbia").first_or_create(id: 57, country_id: 40, code: "BC")
State.where(name: "Prince Edward Island").first_or_create(id: 58, country_id: 40, code: "PE")
State.where(name: "Saskatchewan").first_or_create(id: 59, country_id: 40, code: "SK")
State.where(name: "Alberta").first_or_create(id: 60, country_id: 40, code: "AB")
State.where(name: "Newfoundland And Labrador").first_or_create(id: 61, country_id: 40, code: "NL")
State.where(name: "Aguascalientes").first_or_create(id: 62, country_id: 144, code: "MX.AG")
State.where(name: "Baja California").first_or_create(id: 63, country_id: 144, code: "MX.BN")
State.where(name: "Baja California Sur").first_or_create(id: 64, country_id: 144, code: "MX.BS")
State.where(name: "Campeche").first_or_create(id: 65, country_id: 144, code: "MX.CM")
State.where(name: "Chiapas").first_or_create(id: 66, country_id: 144, code: "MX.CP")
State.where(name: "Chihuahua").first_or_create(id: 67, country_id: 144, code: "MX.CH")
State.where(name: "Coahuila").first_or_create(id: 68, country_id: 144, code: "MX.CA")
State.where(name: "Colima").first_or_create(id: 69, country_id: 144, code: "MX.CL")
State.where(name: "Distrito Federal").first_or_create(id: 70, country_id: 144, code: "MX.DF")
State.where(name: "Durango").first_or_create(id: 71, country_id: 144, code: "MX.DU")
State.where(name: "Guanajuato").first_or_create(id: 72, country_id: 144, code: "MX.GJ")
State.where(name: "Guerrero").first_or_create(id: 73, country_id: 144, code: "MX.GR")
State.where(name: "Hidalgo").first_or_create(id: 74, country_id: 144, code: "MX.HI")
State.where(name: "Jalisco").first_or_create(id: 75, country_id: 144, code: "MX.JA")
State.where(name: "Mexico").first_or_create(id: 76, country_id: 144, code: "MX.MX")
State.where(name: "Michoacan").first_or_create(id: 77, country_id: 144, code: "MX.MC")
State.where(name: "Morelos").first_or_create(id: 78, country_id: 144, code: "MX.MR")
State.where(name: "Nayarit").first_or_create(id: 79, country_id: 144, code: "MX.NA")
State.where(name: "Nuevo Leon").first_or_create(id: 80, country_id: 144, code: "MX.NL")
State.where(name: "Oaxaca").first_or_create(id: 81, country_id: 144, code: "MX.OA")
State.where(name: "Puebla").first_or_create(id: 82, country_id: 144, code: "MX.PU")
State.where(name: "Queretaro").first_or_create(id: 83, country_id: 144, code: "MX.QE")
State.where(name: "Quintana Roo").first_or_create(id: 84, country_id: 144, code: "MX.QR")
State.where(name: "San Luis Potosi").first_or_create(id: 85, country_id: 144, code: "MX.SL")
State.where(name: "Sinaloa").first_or_create(id: 86, country_id: 144, code: "MX.SI")
State.where(name: "Sonora").first_or_create(id: 87, country_id: 144, code: "MX.SO")
State.where(name: "Tabasco").first_or_create(id: 88, country_id: 144, code: "MX.TB")
State.where(name: "Tamaulipas").first_or_create(id: 89, country_id: 144, code: "MX.TM")
State.where(name: "Tlaxcala").first_or_create(id: 90, country_id: 144, code: "MX.TL")
State.where(name: "Veracruz").first_or_create(id: 91, country_id: 144, code: "MX.VE")
State.where(name: "Yucatan").first_or_create(id: 92, country_id: 144, code: "MX.YU")
State.where(name: "Zacatecas").first_or_create(id: 93, country_id: 144, code: "MX.ZA")
State.where(name: "Ain").first_or_create(id: 94, country_id: 76, code: "01")
State.where(name: "Aisne").first_or_create(id: 95, country_id: 76, code: "02")
State.where(name: "Allier").first_or_create(id: 96, country_id: 76, code: "03")
State.where(name: "Alpes-De-Haute-Provence").first_or_create(id: 97, country_id: 76, code: "04")
State.where(name: "Hautes-Alpes").first_or_create(id: 98, country_id: 76, code: "05")
State.where(name: "Alpes-Maritimes").first_or_create(id: 99, country_id: 76, code: "06")
State.where(name: "Ardeche").first_or_create(id: 100, country_id: 76, code: "07")
State.where(name: "Ardennes").first_or_create(id: 101, country_id: 76, code: "08")
State.where(name: "Ariege").first_or_create(id: 102, country_id: 76, code: "09")
State.where(name: "Aube").first_or_create(id: 103, country_id: 76, code: "10")
State.where(name: "Aude").first_or_create(id: 104, country_id: 76, code: "11")
State.where(name: "Aveyron").first_or_create(id: 105, country_id: 76, code: "12")
State.where(name: "Bouches-Du-Rhine").first_or_create(id: 106, country_id: 76, code: "13")
State.where(name: "Calvados").first_or_create(id: 107, country_id: 76, code: "14")
State.where(name: "Cantal").first_or_create(id: 108, country_id: 76, code: "15")
State.where(name: "Charente").first_or_create(id: 109, country_id: 76, code: "16")
State.where(name: "Charente-Maritime").first_or_create(id: 110, country_id: 76, code: "17")
State.where(name: "Cher").first_or_create(id: 111, country_id: 76, code: "18")
State.where(name: "Correze").first_or_create(id: 112, country_id: 76, code: "19")
State.where(name: "Corse-Du-Sud").first_or_create(id: 113, country_id: 76, code: "2A")
State.where(name: "Haute-Corse").first_or_create(id: 114, country_id: 76, code: "2B")
State.where(name: "Cote Dor").first_or_create(id: 115, country_id: 76, code: "21")
State.where(name: "Cotes Darmor").first_or_create(id: 116, country_id: 76, code: "22")
State.where(name: "Creuse").first_or_create(id: 117, country_id: 76, code: "23")
State.where(name: "Dordogne").first_or_create(id: 118, country_id: 76, code: "24")
State.where(name: "Doubs").first_or_create(id: 119, country_id: 76, code: "25")
State.where(name: "Drome").first_or_create(id: 120, country_id: 76, code: "26")
State.where(name: "Eure").first_or_create(id: 121, country_id: 76, code: "27")
State.where(name: "Eure-Et-Loir").first_or_create(id: 122, country_id: 76, code: "28")
State.where(name: "Finistere").first_or_create(id: 123, country_id: 76, code: "29")
State.where(name: "Gard").first_or_create(id: 124, country_id: 76, code: "30")
State.where(name: "Haute-Garonne ").first_or_create(id: 125, country_id: 76, code: "31")
State.where(name: "Gers").first_or_create(id: 126, country_id: 76, code: "32")
State.where(name: "Gironde").first_or_create(id: 127, country_id: 76, code: "33")
State.where(name: "Herault").first_or_create(id: 128, country_id: 76, code: "34")
State.where(name: "Ille-Et-Vilaine").first_or_create(id: 129, country_id: 76, code: "35")
State.where(name: "Indre").first_or_create(id: 130, country_id: 76, code: "36")
State.where(name: "Indre-Et-Loire").first_or_create(id: 131, country_id: 76, code: "37")
State.where(name: "Isere").first_or_create(id: 132, country_id: 76, code: "38")
State.where(name: "Jura").first_or_create(id: 133, country_id: 76, code: "39")
State.where(name: "Landes").first_or_create(id: 134, country_id: 76, code: "40")
State.where(name: "Loir-Et-Cher").first_or_create(id: 135, country_id: 76, code: "41")
State.where(name: "Loire").first_or_create(id: 136, country_id: 76, code: "42")
State.where(name: "Haute-Loire").first_or_create(id: 137, country_id: 76, code: "43")
State.where(name: "Loire-Atlantique").first_or_create(id: 138, country_id: 76, code: "44")
State.where(name: "Loiret").first_or_create(id: 139, country_id: 76, code: "45")
State.where(name: "Lot").first_or_create(id: 140, country_id: 76, code: "46")
State.where(name: "Lot-Et-Garonne").first_or_create(id: 141, country_id: 76, code: "47")
State.where(name: "Lozere").first_or_create(id: 142, country_id: 76, code: "48")
State.where(name: "Maine-Et-Loire").first_or_create(id: 143, country_id: 76, code: "49")
State.where(name: "Manche").first_or_create(id: 144, country_id: 76, code: "50")
State.where(name: "Marne").first_or_create(id: 145, country_id: 76, code: "51")
State.where(name: "Haute-Marne").first_or_create(id: 146, country_id: 76, code: "52")
State.where(name: "Mayenne").first_or_create(id: 147, country_id: 76, code: "53")
State.where(name: "Moselle").first_or_create(id: 148, country_id: 76, code: "54")
State.where(name: "Meuse").first_or_create(id: 149, country_id: 76, code: "55")
State.where(name: "Morbihan").first_or_create(id: 150, country_id: 76, code: "56")
State.where(name: "Meurthe-Et-Moselle").first_or_create(id: 151, country_id: 76, code: "57")
State.where(name: "Nievre").first_or_create(id: 152, country_id: 76, code: "58")
State.where(name: "Nord").first_or_create(id: 153, country_id: 76, code: "59")
State.where(name: "Oise").first_or_create(id: 154, country_id: 76, code: "60")
State.where(name: "Orne").first_or_create(id: 155, country_id: 76, code: "61")
State.where(name: "Pas-De-Calais").first_or_create(id: 156, country_id: 76, code: "62")
State.where(name: "Puy-De-Dome").first_or_create(id: 157, country_id: 76, code: "63")
State.where(name: "Pyrenees-Atlantiques ").first_or_create(id: 158, country_id: 76, code: "64")
State.where(name: "Hautes-Pyrenees").first_or_create(id: 159, country_id: 76, code: "65")
State.where(name: "Pyrenees Orientales").first_or_create(id: 160, country_id: 76, code: "66")
State.where(name: "Bas-Rhin").first_or_create(id: 161, country_id: 76, code: "67")
State.where(name: "Haut-Rhin").first_or_create(id: 162, country_id: 76, code: "68")
State.where(name: "Rhone").first_or_create(id: 163, country_id: 76, code: "69")
State.where(name: "Haute-Saone").first_or_create(id: 164, country_id: 76, code: "70")
State.where(name: "Saone-Et-Loire").first_or_create(id: 165, country_id: 76, code: "71")
State.where(name: "Sarthe").first_or_create(id: 166, country_id: 76, code: "72")
State.where(name: "Savoie").first_or_create(id: 167, country_id: 76, code: "73")
State.where(name: "Haute-Savoie").first_or_create(id: 168, country_id: 76, code: "74")
State.where(name: "Paris").first_or_create(id: 169, country_id: 76, code: "75")
State.where(name: "Seine-Maritime").first_or_create(id: 170, country_id: 76, code: "76")
State.where(name: "Seine-Et-Marne").first_or_create(id: 171, country_id: 76, code: "77")
State.where(name: "Yvelines").first_or_create(id: 172, country_id: 76, code: "78")
State.where(name: "Deux-Sevres").first_or_create(id: 173, country_id: 76, code: "79")
State.where(name: "Somme").first_or_create(id: 174, country_id: 76, code: "80")
State.where(name: "Tarn").first_or_create(id: 175, country_id: 76, code: "81")
State.where(name: "Tarn-Et-Garonne").first_or_create(id: 176, country_id: 76, code: "82")
State.where(name: "Var").first_or_create(id: 177, country_id: 76, code: "83")
State.where(name: "Vaucluse").first_or_create(id: 178, country_id: 76, code: "84")
State.where(name: "Vendee").first_or_create(id: 179, country_id: 76, code: "85")
State.where(name: "Vienne").first_or_create(id: 180, country_id: 76, code: "86")
State.where(name: "Haute-Vienne").first_or_create(id: 181, country_id: 76, code: "87")
State.where(name: "Vosges").first_or_create(id: 182, country_id: 76, code: "88")
State.where(name: "Yonne").first_or_create(id: 183, country_id: 76, code: "89")
State.where(name: "Territoire De Belfort").first_or_create(id: 184, country_id: 76, code: "90")
State.where(name: "Essonne").first_or_create(id: 185, country_id: 76, code: "91")
State.where(name: "Hauts-De-Seine").first_or_create(id: 186, country_id: 76, code: "92")
State.where(name: "Seine-Saint-Denis").first_or_create(id: 187, country_id: 76, code: "93")
State.where(name: "Val-De-Marne").first_or_create(id: 188, country_id: 76, code: "94")
State.where(name: "Val-Doise").first_or_create(id: 189, country_id: 76, code: "95")
State.where(name: "Corse-Du-Sud (Ajaccio)").first_or_create(id: 190, country_id: 76, code: "2A")
State.where(name: "Corse-Haute (Bastia) ").first_or_create(id: 191, country_id: 76, code: "2B")
State.where(name: "Northwest Territories").first_or_create(id: 192, country_id: 40, code: "NT")
State.where(name: "Nunavut").first_or_create(id: 193, country_id: 40, code: "NU")
State.where(name: "Yukon").first_or_create(id: 194, country_id: 40, code: "YT")
State.where(name: "Jervis Bay Territory").first_or_create(id: 196, country_id: 15, code: "AC")
State.where(name: "New South Wales").first_or_create(id: 197, country_id: 15, code: "NS")
State.where(name: "Northern Territory").first_or_create(id: 198, country_id: 15, code: "NT")
State.where(name: "Queensland").first_or_create(id: 199, country_id: 15, code: "QL")
State.where(name: "South Australia").first_or_create(id: 200, country_id: 15, code: "SA")
State.where(name: "Tasmania").first_or_create(id: 201, country_id: 15, code: "TS")
State.where(name: "Victoria").first_or_create(id: 202, country_id: 15, code: "VI")
State.where(name: "Western Australia").first_or_create(id: 203, country_id: 15, code: "WA")
State.where(name: "Australian Capital Territory").first_or_create(id: 204, country_id: 15, code: "AC")
State.where(name: "Acre").first_or_create(id: 205, country_id: 32, code: "AC")
State.where(name: "Alagoas").first_or_create(id: 206, country_id: 32, code: "AL")
State.where(name: "Amazonas").first_or_create(id: 207, country_id: 32, code: "AM")
State.where(name: "Amapa").first_or_create(id: 208, country_id: 32, code: "AP")
State.where(name: "Baia").first_or_create(id: 209, country_id: 32, code: "BA")
State.where(name: "Ceara").first_or_create(id: 210, country_id: 32, code: "CE")
State.where(name: "Distrito Federal").first_or_create(id: 211, country_id: 32, code: "DF")
State.where(name: "Espirito Santo").first_or_create(id: 212, country_id: 32, code: "ES")
State.where(name: "Fernando De Noronha").first_or_create(id: 213, country_id: 32, code: "FN")
State.where(name: "Goias").first_or_create(id: 214, country_id: 32, code: "GO")
State.where(name: "Maranhao").first_or_create(id: 215, country_id: 32, code: "MA")
State.where(name: "Minas Gerais").first_or_create(id: 216, country_id: 32, code: "MG")
State.where(name: "Mato Grosso Do Sul").first_or_create(id: 217, country_id: 32, code: "MS")
State.where(name: "Mato Grosso").first_or_create(id: 218, country_id: 32, code: "MT")
State.where(name: "Para").first_or_create(id: 219, country_id: 32, code: "PA")
State.where(name: "Paraiba").first_or_create(id: 220, country_id: 32, code: "PB")
State.where(name: "Pernambuco").first_or_create(id: 221, country_id: 32, code: "PE")
State.where(name: "Piaui").first_or_create(id: 222, country_id: 32, code: "PI")
State.where(name: "Parana").first_or_create(id: 223, country_id: 32, code: "PR")
State.where(name: "Rio De Janeiro").first_or_create(id: 224, country_id: 32, code: "RJ")
State.where(name: "Rio Grande Do Norte").first_or_create(id: 225, country_id: 32, code: "RN")
State.where(name: "Rondonia").first_or_create(id: 226, country_id: 32, code: "RO")
State.where(name: "Roraima").first_or_create(id: 227, country_id: 32, code: "RR")
State.where(name: "Rio Grande Do Sul").first_or_create(id: 228, country_id: 32, code: "RS")
State.where(name: "Santa Catarina").first_or_create(id: 229, country_id: 32, code: "SC")
State.where(name: "Sergipe").first_or_create(id: 230, country_id: 32, code: "SE")
State.where(name: "Sao Paulo").first_or_create(id: 231, country_id: 32, code: "SP")
State.where(name: "Tocatins").first_or_create(id: 232, country_id: 32, code: "TO")
State.where(name: "Drente").first_or_create(id: 233, country_id: 157, code: "DR")
State.where(name: "Flevoland").first_or_create(id: 234, country_id: 157, code: "FL")
State.where(name: "Friesland").first_or_create(id: 235, country_id: 157, code: "FR")
State.where(name: "Gelderland").first_or_create(id: 236, country_id: 157, code: "GL")
State.where(name: "Groningen").first_or_create(id: 237, country_id: 157, code: "GR")
State.where(name: "Limburg").first_or_create(id: 238, country_id: 157, code: "LB")
State.where(name: "Noord Brabant").first_or_create(id: 239, country_id: 157, code: "NB")
State.where(name: "Noord Holland").first_or_create(id: 240, country_id: 157, code: "NH")
State.where(name: "Overijssel").first_or_create(id: 241, country_id: 157, code: "OV")
State.where(name: "Utrecht").first_or_create(id: 242, country_id: 157, code: "UT")
State.where(name: "Zuid Holland").first_or_create(id: 243, country_id: 157, code: "ZH")
State.where(name: "Zeeland").first_or_create(id: 244, country_id: 157, code: "ZL")
State.where(name: "Avon").first_or_create(id: 245, country_id: 234, code: "AVON")
State.where(name: "Bedfordshire").first_or_create(id: 246, country_id: 234, code: "BEDS")
State.where(name: "Berkshire").first_or_create(id: 247, country_id: 234, code: "BERKS")
State.where(name: "Buckinghamshire").first_or_create(id: 248, country_id: 234, code: "BUCKS")
State.where(name: "Cambridgeshire").first_or_create(id: 249, country_id: 234, code: "CAMBS")
State.where(name: "Cheshire").first_or_create(id: 250, country_id: 234, code: "CHESH")
State.where(name: "Cleveland").first_or_create(id: 251, country_id: 234, code: "CLEVE")
State.where(name: "Cornwall").first_or_create(id: 252, country_id: 234, code: "CORN")
State.where(name: "Cumbria").first_or_create(id: 253, country_id: 234, code: "CUMB")
State.where(name: "Derbyshire").first_or_create(id: 254, country_id: 234, code: "DERBY")
State.where(name: "Devon").first_or_create(id: 255, country_id: 234, code: "DEVON")
State.where(name: "Dorset").first_or_create(id: 256, country_id: 234, code: "DORSET")
State.where(name: "Durham").first_or_create(id: 257, country_id: 234, code: "DURHAM")
State.where(name: "Essex").first_or_create(id: 258, country_id: 234, code: "ESSEX")
State.where(name: "Gloucestershire").first_or_create(id: 259, country_id: 234, code: "GLOUS")
State.where(name: "Greater London").first_or_create(id: 260, country_id: 234, code: "GLONDON")
State.where(name: "Greater Manchester").first_or_create(id: 261, country_id: 234, code: "GMANCH")
State.where(name: "Hampshire").first_or_create(id: 262, country_id: 234, code: "HANTS")
State.where(name: "Hereford & Worcestershire").first_or_create(id: 263, country_id: 234, code: "HERWOR")
State.where(name: "Hertfordshire").first_or_create(id: 264, country_id: 234, code: "HERTS")
State.where(name: "Humberside").first_or_create(id: 265, country_id: 234, code: "HUMBER")
State.where(name: "Isle Of Man").first_or_create(id: 266, country_id: 234, code: "IOM")
State.where(name: "Isle Of Wight").first_or_create(id: 267, country_id: 234, code: "IOW")
State.where(name: "Kent").first_or_create(id: 268, country_id: 234, code: "KENT")
State.where(name: "Lancashire").first_or_create(id: 269, country_id: 234, code: "LANCS")
State.where(name: "Leicestershire").first_or_create(id: 270, country_id: 234, code: "LEICS")
State.where(name: "Lincolnshire").first_or_create(id: 271, country_id: 234, code: "LINCS")
State.where(name: "Merseyside").first_or_create(id: 272, country_id: 234, code: "MERSEY")
State.where(name: "Norfolk").first_or_create(id: 273, country_id: 234, code: "NORF")
State.where(name: "Northamptonshire").first_or_create(id: 274, country_id: 234, code: "NHANTS")
State.where(name: "Northumberland").first_or_create(id: 275, country_id: 234, code: "NTHUMB")
State.where(name: "Nottinghamshire").first_or_create(id: 276, country_id: 234, code: "NOTTS")
State.where(name: "Oxfordshire").first_or_create(id: 277, country_id: 234, code: "OXON")
State.where(name: "Shropshire").first_or_create(id: 278, country_id: 234, code: "SHROPS")
State.where(name: "Somerset").first_or_create(id: 279, country_id: 234, code: "SOM")
State.where(name: "Staffordshire").first_or_create(id: 280, country_id: 234, code: "STAFFS")
State.where(name: "Suffolk").first_or_create(id: 281, country_id: 234, code: "SUFF")
State.where(name: "Surrey").first_or_create(id: 282, country_id: 234, code: "SURREY")
State.where(name: "Sussex").first_or_create(id: 283, country_id: 234, code: "SUSS")
State.where(name: "Warwickshire").first_or_create(id: 284, country_id: 234, code: "WARKS")
State.where(name: "West Midlands").first_or_create(id: 285, country_id: 234, code: "WMID")
State.where(name: "Wiltshire").first_or_create(id: 286, country_id: 234, code: "WILTS")
State.where(name: "Yorkshire").first_or_create(id: 287, country_id: 234, code: "YORK")
State.where(name: "County Antrim").first_or_create(id: 288, country_id: 107, code: "CO ANTRIM")
State.where(name: "County Armagh").first_or_create(id: 289, country_id: 107, code: "CO ARMAGH")
State.where(name: "County Down").first_or_create(id: 290, country_id: 107, code: "CO DOWN")
State.where(name: "County Fermanagh").first_or_create(id: 291, country_id: 107, code: "CO FERMANA")
State.where(name: "County Londonderry").first_or_create(id: 292, country_id: 107, code: "CO DERRY")
State.where(name: "County Tyrone").first_or_create(id: 293, country_id: 107, code: "CO TYRONE")
State.where(name: "County Cavan").first_or_create(id: 294, country_id: 107, code: "CO CAVAN")
State.where(name: "County Donegal").first_or_create(id: 295, country_id: 107, code: "CO DONEGAL")
State.where(name: "County Monaghan").first_or_create(id: 296, country_id: 107, code: "CO MONAGHA")
State.where(name: "County Dublin").first_or_create(id: 297, country_id: 107, code: "CO DUBLIN")
State.where(name: "County Carlow").first_or_create(id: 298, country_id: 107, code: "CO CARLOW")
State.where(name: "County Kildare").first_or_create(id: 299, country_id: 107, code: "CO KILDARE")
State.where(name: "County Kilkenny").first_or_create(id: 300, country_id: 107, code: "CO KILKENN")
State.where(name: "County Laois").first_or_create(id: 301, country_id: 107, code: "CO LAOIS")
State.where(name: "County Longford").first_or_create(id: 302, country_id: 107, code: "CO LONGFOR")
State.where(name: "County Louth").first_or_create(id: 303, country_id: 107, code: "CO LOUTH")
State.where(name: "County Meath").first_or_create(id: 304, country_id: 107, code: "CO MEATH")
State.where(name: "County Offaly").first_or_create(id: 305, country_id: 107, code: "CO OFFALY")
State.where(name: "County Westmeath").first_or_create(id: 306, country_id: 107, code: "CO WESTMEA")
State.where(name: "County Wexford").first_or_create(id: 307, country_id: 107, code: "CO WEXFORD")
State.where(name: "County Wicklow").first_or_create(id: 308, country_id: 107, code: "CO WICKLOW")
State.where(name: "County Galway").first_or_create(id: 309, country_id: 107, code: "CO GALWAY")
State.where(name: "County Mayo").first_or_create(id: 310, country_id: 107, code: "CO MAYO")
State.where(name: "County Leitrim").first_or_create(id: 311, country_id: 107, code: "CO LEITRIM")
State.where(name: "County Roscommon").first_or_create(id: 312, country_id: 107, code: "CO ROSCOMM")
State.where(name: "County Sligo").first_or_create(id: 313, country_id: 107, code: "CO SLIGO")
State.where(name: "County Clare").first_or_create(id: 314, country_id: 107, code: "CO CLARE")
State.where(name: "County Cork").first_or_create(id: 315, country_id: 107, code: "CO CORK")
State.where(name: "County Kerry").first_or_create(id: 316, country_id: 107, code: "CO KERRY")
State.where(name: "County Limerick").first_or_create(id: 317, country_id: 107, code: "CO LIMERIC")
State.where(name: "County Tipperary").first_or_create(id: 318, country_id: 107, code: "CO TIPPERA")
State.where(name: "County Waterford").first_or_create(id: 319, country_id: 107, code: "CO WATERFO")
State.where(name: "Undefined").first_or_create(id: 320, country_id: 235, code: "UNKNOWN")
State.where(name: "US Virgin Islands").first_or_create(id: 321, country_id: 235, code: "US.VI")
State.where(name: "Puerto Rico").first_or_create(id: 322, country_id: 235, code: "US.PR")
State.where(name: "None").first_or_create(id: 323, country_id: 999999, code: "")

massachusetts = State.where(name: "Massachusetts").first_or_create(
  code: "MA",
  country: united_states,
)
california = State.where(name: "California").first_or_create(
  code: "CA",
  country: united_states,
)

# Institutions
ucnrs = Institution.where(name: "UC Nature").first_or_create(
  city: "Oakland",
  state: california,
  country: united_states,
  institution_type: :university_of_california,
)

# Reserves
uc_reserve = Reserve.where(name: "UC Reserve").first_or_create(
  short_name: "UC Reserve",
  pulldown_name: "UC Reserve",
  address_country: united_states,
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: true,
  public_projects_accepted: true,
  housing_projects_accepted: true,
  conference_projects_accepted: true,
  amenity_group_label_1: "Housing",
)
yosemite_geographical_research_lab = Reserve.where(name: "Yosemite Geographical Research Laboratory").first_or_create(
  short_name: "Yosemite Geo-Lab",
  pulldown_name: "Yosemite Geographical Research Laboratory",
  address_country: united_states,
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: false,
  public_projects_accepted: false,
  housing_projects_accepted: false,
  conference_projects_accepted: false,
  amenity_group_label_1: "Laboratory Space",
)
harvard_yard = Reserve.where(name: "Harvard Yard").first_or_create(
  short_name: "Harvard Yard",
  pulldown_name: "Harvard Yard",
  address_country: united_states,
  address_state: massachusetts,
  research_projects_accepted: false,
  class_projects_accepted: true,
  public_projects_accepted: false,
  housing_projects_accepted: false,
  conference_projects_accepted: false,
  amenity_group_label_1: "Parking Lot",
)
big_sur_conference_center = Reserve.where(name: "Big Sur Conference Center").first_or_create(
  short_name: "Big Sur Conference",
  pulldown_name: "Big Sur Conference Center",
  address_country: united_states,
  address_state: california,
  research_projects_accepted: false,
  class_projects_accepted: false,
  public_projects_accepted: false,
  housing_projects_accepted: false,
  conference_projects_accepted: true,
  amenity_group_label_1: "Auditoriums",
)
sunny_los_angeles_marine_center = Reserve.where(name: "Sunny Los Angeles Marine Center").first_or_create(
  short_name: "L.A. Marine Ctr.",
  pulldown_name: "Sunny Los Angeles Marine Center",
  address_country: united_states,
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: true,
  public_projects_accepted: true,
  housing_projects_accepted: true,
  conference_projects_accepted: true,
  amenity_group_label_1: "Waterfront",
)

# Amenities
uc_reserve_uc_public_housing_amenity = Amenity
  .where(title: "UC Public Housing Amenity", reserve: uc_reserve)
  .first_or_create(
    sort_order: 1,
    units_type: "person",
    time_type: "day",
    visible: true,
    group_number: "1",
  )
uc_reserve_normal_rate_category = AmenityRateCategory
  .where(description: "Normal Price", reserve: uc_reserve)
  .first_or_create(
    sort_order: 1,
    state_university: false,
    state_college: true,
    community_college: true,
    other_state_institution: true,
    outside_state: true,
    international: true,
    K12: true,
    nongovernmental: true,
    governmental: false,
    business: true,
    other: true,
  )
uc_reserve_uc_rate_category = AmenityRateCategory
  .where(description: "UC Price", reserve: uc_reserve)
  .first_or_create(
    sort_order: 2,
    state_university: true,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: false,
    governmental: false,
    business: false,
    other: false,
  )
uc_reserve_government_rate_category = AmenityRateCategory
  .where(description: "Government Rate", reserve: uc_reserve)
  .first_or_create(
    sort_order: 3,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: false,
    governmental: true,
    business: false,
    other: false,
  )
AmenityRate
  .find_or_initialize_by(amenity: uc_reserve_uc_public_housing_amenity, amenity_rate_category: uc_reserve_uc_rate_category)
  .update(
    rate: 45.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: uc_reserve_uc_public_housing_amenity, amenity_rate_category: uc_reserve_government_rate_category)
  .update(
    rate: 1.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: uc_reserve_uc_public_housing_amenity, amenity_rate_category: uc_reserve_normal_rate_category)
  .update(
    rate: 3.00,
  )


yosemite_geographical_research_lab_day_use = Amenity
  .where(title: "Day Use", reserve: yosemite_geographical_research_lab)
  .first_or_create(
    sort_order: 1,
    units_type: "person",
    time_type: "day",
    visible: true,
    group_number: "1",
  )
yosemite_geographical_research_lab_normal_category = AmenityRateCategory
  .where(description: "Normal Price", reserve: yosemite_geographical_research_lab)
  .first_or_create(
    sort_order: 1,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: true,
    governmental: false,
    business: true,
    other: true,
  )
yosemite_geographical_research_lab_edu_category = AmenityRateCategory
  .where(description: "EDU Rate", reserve: yosemite_geographical_research_lab)
  .first_or_create(
    sort_order: 2,
    state_university: true,
    state_college: true,
    community_college: true,
    other_state_institution: true,
    outside_state: true,
    international: true,
    K12: true,
    nongovernmental: false,
    governmental: false,
    business: false,
    other: false,
  )
yosemite_geographical_research_lab_gov_category = AmenityRateCategory
  .where(description: "Government Rate", reserve: yosemite_geographical_research_lab)
  .first_or_create(
    sort_order: 3,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: false,
    governmental: true,
    business: false,
    other: false,
  )
AmenityRate
  .find_or_initialize_by(amenity: yosemite_geographical_research_lab_day_use,
    amenity_rate_category: yosemite_geographical_research_lab_normal_category)
  .update(
    rate: 12.50,
  )
AmenityRate
  .find_or_initialize_by(amenity: yosemite_geographical_research_lab_day_use,
    amenity_rate_category: yosemite_geographical_research_lab_edu_category)
  .update(
    rate: 1.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: yosemite_geographical_research_lab_day_use,
    amenity_rate_category: yosemite_geographical_research_lab_gov_category)
  .update(
    rate: 3.00,
  )

harvard_yard_botanical_garden_pavillion = Amenity
  .where(title: "Botanical Garden Pavillion", reserve: harvard_yard)
  .first_or_create(
    sort_order: 1,
    units_type: "person",
    time_type: "hour",
    visible: true,
    group_number: "1",
  )
harvard_yard_normal_category = AmenityRateCategory
  .where(description: "Normal Price", reserve: harvard_yard)
  .first_or_create(
    sort_order: 1,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: true,
    governmental: false,
    business: true,
    other: true,
  )
harvard_yard_edu_category = AmenityRateCategory
  .where(description: "EDU Rate", reserve: harvard_yard)
  .first_or_create(
    sort_order: 2,
    state_university: true,
    state_college: true,
    community_college: true,
    other_state_institution: true,
    outside_state: true,
    international: true,
    K12: true,
    nongovernmental: false,
    governmental: false,
    business: false,
    other: false,
  )
harvard_yard_gov_category = AmenityRateCategory
  .where(description: "Government Rate", reserve: harvard_yard)
  .first_or_create(
    sort_order: 3,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: false,
    governmental: true,
    business: false,
    other: false,
  )
AmenityRate
  .find_or_initialize_by(amenity: harvard_yard_botanical_garden_pavillion,
    amenity_rate_category: harvard_yard_normal_category)
  .update(
    rate: 15.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: harvard_yard_botanical_garden_pavillion,
    amenity_rate_category: harvard_yard_edu_category)
  .update(
    rate: 14.99,
  )
AmenityRate
  .find_or_initialize_by(amenity: harvard_yard_botanical_garden_pavillion,
    amenity_rate_category: harvard_yard_gov_category)
  .update(
    rate: 10.00,
  )

big_sur_conference_center_auditorium_one = Amenity
  .where(title: "Auditorium #1", reserve: big_sur_conference_center)
  .first_or_create(
    sort_order: 1,
    units_type: "facility",
    time_type: "4 hours",
    visible: true,
    group_number: "1",
  )
big_sur_conference_center_normal_category = AmenityRateCategory
  .where(description: "Normal Price", reserve: big_sur_conference_center)
  .first_or_create(
    sort_order: 1,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: true,
    governmental: false,
    business: true,
    other: true,
  )
big_sur_conference_center_edu_category = AmenityRateCategory
  .where(description: "EDU Rate", reserve: big_sur_conference_center)
  .first_or_create(
    sort_order: 2,
    state_university: true,
    state_college: true,
    community_college: true,
    other_state_institution: true,
    outside_state: true,
    international: true,
    K12: true,
    nongovernmental: false,
    governmental: false,
    business: false,
    other: false,
  )
big_sur_conference_center_gov_category = AmenityRateCategory
  .where(description: "Government Rate", reserve: big_sur_conference_center)
  .first_or_create(
    sort_order: 3,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: false,
    governmental: true,
    business: false,
    other: false,
  )
AmenityRate
  .find_or_initialize_by(amenity: big_sur_conference_center_auditorium_one,
    amenity_rate_category: big_sur_conference_center_normal_category)
  .update(
    rate: 500.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: big_sur_conference_center_auditorium_one,
    amenity_rate_category: big_sur_conference_center_edu_category)
  .update(
    rate: 50.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: big_sur_conference_center_auditorium_one,
    amenity_rate_category: big_sur_conference_center_gov_category)
  .update(
    rate: 75.00,
  )

sunny_los_angeles_marine_center_beach_access = Amenity
  .where(title: "Beach Access", reserve: sunny_los_angeles_marine_center)
  .first_or_create(
    sort_order: 1,
    units_type: "use",
    time_type: "day",
    visible: true,
    group_number: "1",
  )
sunny_los_angeles_marine_center_normal_category = AmenityRateCategory
  .where(description: "Normal Price", reserve: sunny_los_angeles_marine_center)
  .first_or_create(
    sort_order: 1,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: true,
    governmental: false,
    business: true,
    other: true,
  )
sunny_los_angeles_marine_center_edu_category = AmenityRateCategory
  .where(description: "EDU Rate", reserve: sunny_los_angeles_marine_center)
  .first_or_create(
    sort_order: 2,
    state_university: true,
    state_college: true,
    community_college: true,
    other_state_institution: true,
    outside_state: true,
    international: true,
    K12: true,
    nongovernmental: false,
    governmental: false,
    business: false,
    other: false,
  )
sunny_los_angeles_marine_center_gov_category = AmenityRateCategory
  .where(description: "Government Rate", reserve: sunny_los_angeles_marine_center)
  .first_or_create(
    sort_order: 3,
    state_university: false,
    state_college: false,
    community_college: false,
    other_state_institution: false,
    outside_state: false,
    international: false,
    K12: false,
    nongovernmental: false,
    governmental: true,
    business: false,
    other: false,
  )
AmenityRate
  .find_or_initialize_by(amenity: sunny_los_angeles_marine_center_beach_access,
    amenity_rate_category_id: sunny_los_angeles_marine_center_normal_category)
  .update(
    rate: 29.99,
  )
AmenityRate
  .find_or_initialize_by(amenity: sunny_los_angeles_marine_center_beach_access,
    amenity_rate_category_id: sunny_los_angeles_marine_center_edu_category)
  .update(
    rate: 0.00,
  )
AmenityRate
  .find_or_initialize_by(amenity: sunny_los_angeles_marine_center_beach_access,
    amenity_rate_category_id: sunny_los_angeles_marine_center_gov_category)
  .update(
    rate: 20.00,
  )

# Users
public_project_owner = User.where(email: "public-project@ucnature.org").first_or_create(
  first_name: "Public",
  last_name: "Use",
  role: "Faculty",
  emergency_contact_full_name: "Uncle Sam",
  emergency_contact_phone_number: "508 424 2424",
  phone_number: "508 424 2424",
  address_line_1: "123 Main St.",
  address_city: "Sacramento",
  address_state: california,
  address_country: united_states,
  address_postal_code: "99999",
  terms_accepted_at: 10.years.ago,
  confirmed_at: 10.years.ago,
  institution: ucnrs,
  password: "PUBL1Cpassword",
)
user = User.where(email: "project-owner@ucnature.org").first_or_create(
  first_name: "Project",
  last_name: "Owner",
  role: "Docent",
  emergency_contact_full_name: "Emergency Contact",
  emergency_contact_phone_number: "000 867 5309",
  phone_number: "000 867 5309",
  address_line_1: "456 Main St.",
  address_city: "San Francisco",
  address_state: california,
  address_country: united_states,
  address_postal_code: "11111",
  terms_accepted_at: 5.years.ago,
  confirmed_at: 5.years.ago,
  institution: ucnrs,
  password: "PR0JECTowner",
)

# Projects
Project.where(title: "General Day Use").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Community Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Other Public Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Volunteer Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Private Class (not a University level class or K-12 class").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "K-12 Class").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Fundraiser Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Caldera Eruption Prevention Research").first_or_create(
  owner: user,
  applicant: user,
  reserve: yosemite_geographical_research_lab,
  project_type: :research,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(2001, 1, 1),
  end_date: Date.new(2099, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "How to Park Your Car in...").first_or_create(
  owner: user,
  applicant: user,
  reserve: harvard_yard,
  project_type: :class,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(2015, 6, 1),
  end_date: Date.new(2025, 6, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Big Sur Conference").first_or_create(
  owner: user,
  applicant: user,
  reserve: big_sur_conference_center,
  project_type: :meeting,
  abstract: "Abstract Lorem Ipsum",
  start_date: Date.new(2005, 4, 1),
  end_date: Date.new(2028, 4, 1),
  status: 'Open',
  permits_completed: true,
)

involvements = ["", :mammal, :reptile, :amphibian, :fish, :bird, :plant_fungi_soil, :threatened_endangered]
[:federal, :state, :local, :institution].each do |authority|
  8.times do |index|
    Permit.where(question: "Does this project violate #{authority} #{involvements[index]} law?").first_or_create(
      authority: authority,
      sort_order: 1,
      description: "If so, you should check the laws:",
      url1: "https://law.com",
      url1_description: "All About Law",
      url2: "https://dontbreakthe.law",
      url2_description: "Don't Break the Law",
      visible: true,
      research: true,
      university_class: true,
      conference: true,
      public: true,
      housing: true,
      involves_all: index == 0,
      involves_mammals: index == 1,
      involves_reptiles: index == 2,
      involves_amphibians: index == 3,
      involves_fish: index == 4,
      involves_birds: index == 5,
      involves_plants_fungi_soil: index == 6,
      threatened_endangered_flag: index == 7,
      statement: "#{authority} #{involvements[index]} law is violated",
    )
  end
end
