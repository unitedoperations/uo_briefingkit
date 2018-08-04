//by BlackHawk

private _newIndex = player createDiarySubject ["GearIndex","Loadouts"];

	private _playerSide = side player;
	private _grpText = "";
	private _grpArray = [];

{
	private _grpText = "";
	if (side _x == _playerSide) then {
		private _group = _x;
		private _show = false;
		private _textToDisplay = "";
		{
			private _unit = _x;
			if ((alive _unit) && ((isMultiplayer) && (_unit in playableUnits) || ((!isMultiplayer) && (_unit in switchableUnits))) && (side _unit == _playerSide)) then {

				private _getPicture = {
					params ["_name", "_dimensions", ["_type", "CfgWeapons"]];
					private _image = getText(configFile >> _type >> _name >> "picture");
					if (_image == "") exitWith {""};
					if ((_image find ".paa") == -1) then {_image = _image + ".paa";};
					format ["<img image='%1' width='%2' height='%3'/>", _image, _dimensions select 0, _dimensions select 1]
				};

				private _lobbyName = if (((roleDescription _x) find "@") != -1) then {((roleDescription _x) splitString "@") select 0} else {roleDescription _x};
				if (_lobbyName == "") then {_lobbyName = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")};

				// Creating briefing text
				_textToDisplay = _textToDisplay + format ["", rank _unit];
				_textToDisplay = _textToDisplay +
					format ["<img image='\A3\Ui_f\data\GUI\Cfg\Ranks\%4_gs.paa' width='16' height='16'/> <font size='14' color='%5'>%1 - %2</font> - %3kg<br/>",
						name _unit,
						_lobbyName,
						round ((loadAbs _unit) *0.1 * 0.45359237 * 10) / 10,
						toLower rank _unit,
						if (_unit == player) then {"#5555FF"} else {"#FFFFFF"}
					];

				private _getApparelPicture = {
					if (_this != "") then {
						private _name  = getText(configFile >> "CfgWeapons" >> _this >> "displayName");
						if (_name == "") then {
							_name = getText(configFile >> "CfgVehicles" >> _this >> "displayName");
						};
						_pic = [_this, [40, 40]] call _getPicture;
						if (_pic == "") then {
							_pic = [_this, [40, 40], "CfgVehicles"] call _getPicture;
						};
						_pic + format ["<execute expression='systemChat ""%1""'>*</execute>  ", _name]
					}
					else {
						""
					};
				};
				{_textToDisplay = _textToDisplay + (_x call _getApparelPicture)} forEach [uniform _unit, vest _unit, backpack _unit, headgear _unit];

				_textToDisplay = _textToDisplay + "<br/>";

				_sWeaponName = secondaryWeapon _unit;
				_hWeaponName = handgunWeapon _unit;
				_weaponName = primaryWeapon _unit;

				//display both weapon and it's attachments
				private _getWeaponPicture = {
					params ["_weaponName", "_weaponItems"];
					private _str = "";
					if (_weaponName != "") then {
						_str = _str + ([_weaponName, [80, 40]] call _getPicture);
						{
							if (_x != "") then {
								_str = _str + ([_x, [40, 40]] call _getPicture);
							};
						} forEach _weaponItems;
					};
					_str
				};

				//display array of magazines
				private _displayMags = {
					_textToDisplay = _textToDisplay + "  ";
					{
						private _name = _x;
						private _itemCount = {_x == _name} count _allMags;
						private _displayName = getText(configFile >> "CfgMagazines" >> _name >> "displayName");
						_textToDisplay = _textToDisplay + ([_name, [32,32], "CfgMagazines"] call _getPicture) + format ["<execute expression='systemChat ""%2""'>x%1</execute> ", _itemCount, _displayName];
					} forEach _this;
					_textToDisplay = _textToDisplay + "<br/>";
				};

				//get magazines for a weapon and it's muzzles (grenade launchers etc.)
				private _getMuzzleMags = {
					private _result = getArray(configFile >> "CfgWeapons" >> _this >> "magazines");
					{
						if (_x != "this" && _x != "SAFE") then {
							{_result pushBackUnique _x} forEach getArray (configFile >> "CfgWeapons" >> _this >> _x >> "magazines");
						};
					} forEach getArray (configFile >> "CfgWeapons" >> _this >> "muzzles");
					_result = _result apply {toLower _x};
					_result
				};

				// Primary weapon
				if (_weaponName != "") then {
					private _name = getText(configFile >> "CfgWeapons" >> _weaponName >> "displayName");
					_textToDisplay = _textToDisplay + format ["<font color='#FFFF00'>Primary: </font>%1<br/>", _name] + ([_weaponName, primaryWeaponItems _unit] call _getWeaponPicture);
				};
				
				private _allMags = magazines _unit;
				_allMags = _allMags apply {toLower _x};
				private _primaryMags = _allMags arrayIntersect (_weaponName call _getMuzzleMags);

				_primaryMags call _displayMags;

				// Secondary
				private _secondaryMags = [];
				if (_sWeaponName != "") then {
					private _name = getText(configFile >> "CfgWeapons" >> _sWeaponName >> "displayName");
					_textToDisplay = _textToDisplay + format ["<font color='#FFFF00'>Launcher: </font>%1<br/>", _name];
					_textToDisplay = _textToDisplay + ([_sWeaponName, secondaryWeaponItems _unit] call _getWeaponPicture);

					_secondaryMags = _allMags arrayIntersect (_sWeaponName call _getMuzzleMags);
					
					_secondaryMags call _displayMags;
				};

				// Handgun
				private _handgunMags = [];
				if (_hWeaponName != "") then {
					private _name = getText(configFile >> "CfgWeapons" >> _hWeaponName >> "displayName");
					_textToDisplay = _textToDisplay + format ["<font color='#FFFF00'>Sidearm: </font>%1<br/>", _name];
					_textToDisplay = _textToDisplay + ([_hWeaponName, handgunItems _unit] call _getWeaponPicture);

					_handgunMags = _allMags arrayIntersect (_hWeaponName call _getMuzzleMags);

					_handgunMags call _displayMags;
				};

				_allMags = _allMags - _primaryMags;
				_allMags = _allMags - _secondaryMags;
				_allMags = _allMags - _handgunMags;

				private _radios = [];
				private _allItems = items _unit;
				
				{
					if ((toLower _x) find "acre_" != -1) then {
						_radios pushBack _x;
					};
				} forEach _allItems;
				_allItems = _allItems - _radios;

				_textToDisplay = _textToDisplay + format ["<font color='#FFFF00'>Magazines and items: </font>(Click count for info.)<br/>", _x];

				//display radios, then magazines, inventory items and assigned items
				{
					_x params ["_items", "_cfgType"];
					while {count _items > 0} do {
						private _name = _items select 0;
						private _itemCount = {_x == _name} count _items;
						private _displayName = getText(configFile >> _cfgType >> _name >> "displayName");
						_textToDisplay = _textToDisplay + ([_name, [32,32], _cfgType] call _getPicture) + format ["<execute expression='systemChat ""%2""'>x%1</execute>  ", _itemCount, _displayName];
						_items = _items - [_name];
					};
				} forEach [[_radios, "CfgWeapons"], [_allMags, "CfgMagazines"], [_allItems, "CfgWeapons"], [assignedItems _unit, "CfgWeapons"]];

				_textToDisplay = _textToDisplay + "<br/>============================================================<br/>";

				_show = true;
			};
		} foreach units _group;
		
		if _show then {
			_grpText = _grpText + _textToDisplay;
		};
		if (_grpText != "") then {_grpArray set [count _grpArray,["GearIndex", [groupID _group, _grpText]]]};
	};
} foreach allGroups;

while {count _grpArray > 0} do {
	_wrekt = _grpArray call BIS_fnc_arrayPop;
	player createDiaryRecord _wrekt;
};

UO_showOrbat = {
	private _text = "<br/><execute expression='if (time < 1) then {call UO_showOrbat}'>Refresh</execute> (click to show JIPs)<br/><br/>";

	private _getPicture = {
		params ["_name", "_dimensions", ["_type", "CfgWeapons"]];
		private _image = getText(configFile >> _type >> _name >> "picture");
		if (_image == "") exitWith {""};
		if ((_image find ".paa") == -1) then {_image = _image + ".paa";};
		format ["<img image='%1' width='%2' height='%3'/>", _image, _dimensions select 0, _dimensions select 1]
	};

	{
		if (side _x == side player && !isNull leader _x && {isPlayer leader _x}) then {
			_text = _text + format ["<font size='20' color='#FFFF00'>%1</font>", groupID _x] + "<br/>";
			{
				private _radios = "";
				{
					if ((toLower _x) find "acre_" != -1) then {
						_radios = _radios + ([_x, [28,28]] call _getPicture);
					};
				} forEach items _x;

				private _lobbyName = if (((roleDescription _x) find "@") != -1) then {((roleDescription _x) splitString "@") select 0} else {roleDescription _x};
				if (_lobbyName == "") then {_lobbyName = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")};

				_text = _text + 
					format ["%7<img image='\A3\Ui_f\data\GUI\Cfg\Ranks\%3_gs.paa' width='15' height='15'/> <font size='16' color='%6'>%1 | %2</font> %8<br/>%4 %5<br/>",
						name _x,
						_lobbyName,
						rank _x,
						[primaryWeapon _x, [56,28]] call _getPicture,
						[secondaryWeapon _x, [56,28]] call _getPicture,
						if (_x == player) then {"#5555FF"} else {"#FFFFFF"},
						if (_forEachIndex == 0) then {""} else {"     "},
						_radios
					];
			} forEach [leader _x] + (units _x - [leader _x]);
		};
	} forEach allGroups;

	_text = _text + "<br/>============================================================";
	_text = _text + "<br/>============================================================";
	
	player createDiaryRecord ["GearIndex", ["ORBAT", _text]];
};

call UO_showOrbat;
