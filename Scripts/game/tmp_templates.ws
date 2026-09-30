/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
exec function spawnt( template_nbr : int, optional distance : float)
{	
	switch ( template_nbr )
	{
		
		case 1:		
		case 2:		
		case 3:		
		case 4:		
		case 5:		
		case 6:		
		case 7:		
		case 8:		
		case 9:		
			spawnt_inquistion(template_nbr, distance);
			break;
			
		
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
		case 16:
		case 17:
		case 18:
		case 19:
		case 20:
		case 21:
		case 22:
		case 23:
		case 24:
		case 25:
		case 26:
			spawnt_nilfgard(template_nbr, distance);
			break;
			
		
		case 27:
		case 29:
		case 31:
		case 33:
		case 35:
		case 37:
		case 39:
		case 41:
		case 43:
		case 45:
		case 47:
		case 49:
		case 51:
		case 53:
		case 55:
		case 57:
		case 59:
			spawnt_nml_t1(template_nbr, distance);
			break;
			
		case 28:	
		case 30:
		case 32:
		case 34:
		case 36:
		case 38:
		case 40:
		case 42:
		case 44:
		case 46:
		case 48:
		case 50:
		case 52:
		case 54:
		case 56:
		case 58:
		case 60:
			spawnt_nml_t2(template_nbr, distance);
			break;
			
		
		case 61:
		case 62:
		case 63:
		case 64:
		case 65:
		case 66:
		case 67:
		case 68:
		case 69:
		case 70:
		case 71:
		case 72:
		case 73:
		case 74:
		case 75:
		case 76:
		case 77:
		case 78:
		case 79:
		case 80:
		case 81:
		case 82:
			spawnt_novigrad(template_nbr, distance);
			break;	
			
		
		case 83:
		case 84:
		case 85:
		case 86:
		case 87:
		case 88:
		case 89:
		case 90:
		case 91:
		case 92:
		case 93:
		case 94:
		case 95:
		case 96:
		case 97:
		case 98:
		case 99:
			spawnt_redania(template_nbr, distance);
			break;	
			
		
		case 100:
		case 102:
		case 104:
		case 106:
		case 108:
		case 110:
		case 112:
		case 114:
		case 116:
		case 118:
		case 120:
		case 122:
		case 124:
		case 126:
		case 128:
		case 130:
		case 132:
			spawnt_skellige_t1(template_nbr, distance);
			break;
		
		case 101:	
		case 103:
		case 105:
		case 107:
		case 109:
		case 111:
		case 113:
		case 115:
		case 117:
		case 119:
		case 121:
		case 123:
		case 125:
		case 127:
		case 129:
		case 131:
		case 133:
			spawnt_skellige_t2(template_nbr, distance);
			break;
			
		
		case 134:	
		case 135:
		case 136:
		case 137:
		case 138:
		case 139:
		case 140:
			spawnt_wild_hunt(template_nbr, distance);
			break;
	}
}

function spawnt_inquistion(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 1:		
			if ( RandF() > 0.5 ) 
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 2, distance);
			break;
		case 2:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 2, distance);
			break;
		case 3:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 1, distance);
			break;
		case 4:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 1, distance);
			break;
		case 5:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			break;
		case 6:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			break;	
		case 7:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 1, distance);
			break;
		case 8:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t2.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 1, distance);
			break;	
		case 9:		
			if ( RandF() > 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\inquisition\inq_crossbow.w2ent", 1, distance);
			break;
	}
}

function spawnt_nilfgard(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 10:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;
		case 11:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 1, distance);
			break;
		case 12:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 2, distance);
			break;
		case 13:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 1, distance);
			break;
		case 14:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			break;
		case 15:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;	
		case 16:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;
		case 17:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 1, distance);
			break;
		case 18:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 2, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;
		case 19:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 2, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;
		case 20:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 1, distance);
			break;
		case 21:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 2, distance);
			break;
		case 22:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 1, distance);
			break;
		case 23:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;
		case 24:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			break;
		case 25:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 1, distance);
			break;
		case 26:
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_halberd.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_hammer.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nilfgard\nlg_crossbow.w2ent", 2, distance);
			break;
	}
}

function spawnt_nml_t1(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 27:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 2, distance);
			break;
		case 29:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 1, distance);
			break;
		case 31:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 33:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 1, distance);
			break;
		case 35:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 37:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 39:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 1, distance);
			break;
		case 41:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 43:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 45:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 2, distance);
			break;
		case 47:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 1, distance);
			break;
		case 49:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			break;
		case 51:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 1, distance);
			break;
		case 53:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 55:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			break;
		case 57:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_axe.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 1, distance);
			break;
		case 59:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_club.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_spear.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_bow.w2ent", 2, distance);
			break;
	}
}

function spawnt_nml_t2(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 28:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 2, distance);
			break;
		case 30:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 1, distance);
			break;
		case 32:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 34:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 1, distance);
			break;
		case 36:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 38:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 40:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 1, distance);
			break;
		case 42:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 44:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 46:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 2, distance);
			break;
		case 48:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 1, distance);
			break;
		case 50:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			break;
		case 52:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 1, distance);
			break;
		case 54:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 56:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			break;
		case 58:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 1, distance);
			break;
		case 60:
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\nml\nml_crossbow.w2ent", 2, distance);
			break;
	}
}

function spawnt_novigrad(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 61:	
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_hammer.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_bow.w2ent", 2, distance);
			break;
		case 62:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 2, distance);
			break;
		case 63:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_hammer.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_bow.w2ent", 1, distance);
			break;
		case 64:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 1, distance);
			break;
		case 65:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_hammer.w2ent", 1, distance);
			break;
		case 66:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;
		case 67:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_bow.w2ent", 1, distance);
			break;
		case 68:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 1, distance);
			break;	
		case 69:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			break;	
		case 70:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;	
		case 71:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;	
		case 72:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 1, distance);
			break;	
		case 73:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;	
		case 74:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;	
		case 75:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 1, distance);
			break;	
		case 76:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 2, distance);
			break;	
		case 77:
			if ( RandF() < 0.33 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t1.w2ent", 1, distance);
				else if ( RandF() < 0.66 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_club.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t1.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_hammer.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_bow.w2ent", 1, distance);
			break;
		case 78:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 1, distance);
			break;
		case 79:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;	
		case 80:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			break;	
		case 81:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_1h_mace_t2.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 1, distance);
			break;	
		case 82:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_mace.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_shield_sword.w2ent", 1, distance);
			if ( RandF() < 0.5 )
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_sword_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_2h_halberd.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\novigrad\nov_crossbow.w2ent", 2, distance);
			break;
	}
}

function spawnt_redania(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 83:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 84:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 1, distance);
			break;	
		case 85:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 2, distance);
			break;	
		case 86:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 1, distance);
			break;	
		case 87:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			break;	
		case 88:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 89:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 90:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 1, distance);
			break;	
		case 91:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 92:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 93:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 1, distance);
			break;	
		case 94:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 2, distance);
			break;	
		case 95:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 1, distance);
			break;	
		case 96:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 97:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);
			break;	
		case 98:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_1h_mace.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 1, distance);
			break;	
		case 99:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_sword.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_shield_mace.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_halberd.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\redania\red_2h_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\redania\red_crossbow.w2ent", 2, distance);
			break;	
	}
}

function spawnt_skellige_t1(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 100:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 2, distance);
			break;
		case 102:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 104:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			break;
		case 106:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 108:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);
			break;
		case 110:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			break;
		case 112:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 114:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);
			break;
		case 116:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			break;
		case 118:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 2, distance);
			break;
		case 120:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 122:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			break;
		case 124:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 126:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);		
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);
			break;
		case 128:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);		
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			break;
		case 130:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 132:	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t1.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_club.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_spear.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
	}
}

function spawnt_skellige_t2(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 101:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 2, distance);
			break;
		case 103:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 105:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			break;
		case 107:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 109:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 2, distance);
			break;
		case 111:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			break;
		case 113:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 115:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 2, distance);
			break;
		case 117:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			break;
		case 119:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 2, distance);
			break;
		case 121:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 123:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			break;
		case 125:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 127:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 2, distance);
			break;
		case 129:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			break;
		case 131:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_1h_sword.w2ent", 1, distance);	
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
		case 133:
			if ( RandF() < 0.50 )
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_axe_t2.w2ent", 1, distance);
				else
				spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_shield_sword.w2ent", 1, distance);	
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_2h_axe.w2ent", 1, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\skellige\ske_bow.w2ent", 1, distance);
			break;
	}
}

function spawnt_wild_hunt(template_nbr : int, optional distance : float)
{
	switch( template_nbr )
	{
		case 134:	
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_2h_sword.w2ent", 1, distance);
			break;	
		case 135:
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_2h_sword.w2ent", 2, distance);
			break;
		case 136:
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "characters\npc_entities\monsters\wildhunt_minion.w2ent", 2, distance);		
			break;
		case 137:
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_1h_sword.w2ent", 1, distance);
			spawnt_internal ( "characters\npc_entities\monsters\wildhunt_minion.w2ent", 4, distance);		
			break;
		case 138:
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "characters\npc_entities\monsters\wildhunt_minion.w2ent", 2, distance);		
			break;
		case 139:
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "characters\npc_entities\monsters\wildhunt_minion.w2ent", 4, distance);		
			break;
		case 140:
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_1h_sword.w2ent", 2, distance);
			spawnt_internal ( "gameplay\templates\characters\presets\wild_hunt\wlh_2h_sword.w2ent", 1, distance);
			spawnt_internal ( "characters\npc_entities\monsters\wildhunt_minion.w2ent", 2, distance);		
			break;
	}
}

function spawnt_internal(nam : string, optional quantity : int, optional distance : float)
{
	var ent : CEntity;
	var horse : CEntity;
	var pos, cameraDir, player, posFin, normal : Vector;
	var rot : EulerAngles;
	var i, sign : int;
	var s,r,x,y : float;
	var template : CEntityTemplate;
	var horseTemplate : CEntityTemplate;
	var horseTag : array<name>;
	
	quantity = Max(quantity, 1);
	
	rot = thePlayer.GetWorldRotation();	
	rot.Yaw += 180;		
	
	
	cameraDir = theCamera.GetCameraDirection();
	
	if( distance == 0 ) distance = 3; 
	cameraDir.X *= distance;	
	cameraDir.Y *= distance;
	
	
	player = thePlayer.GetWorldPosition();
	
	
	pos = cameraDir + player;	
	pos.Z = player.Z;
	
	
	posFin.Z = pos.Z;			
	s = quantity / 0.2;			
	r = SqrtF(s/Pi());
	
	
	template = (CEntityTemplate)LoadResource(nam, true);
	
	
	
		
	for(i=0; i<quantity; i+=1)
	{		
		x = RandF() * r;			
		y = RandF() * (r - x);		
		
		if(RandRange(2))					
			sign = 1;
		else
			sign = -1;
			
		posFin.X = pos.X + sign * x;	
		
		if(RandRange(2))					
			sign = 1;
		else
			sign = -1;
			
		posFin.Y = pos.Y + sign * y;	
				
		theGame.GetWorld().StaticTrace( posFin + 5, posFin - 5, posFin, normal );
		
		ent = theGame.CreateEntity(template, posFin, rot);
		
		if ( horseTemplate )
		{
			horseTag.PushBack('enemy_horse');
			horse = theGame.CreateEntity(horseTemplate, posFin, rot,true,false,false,PM_DontPersist,horseTag);
			
			
			
			((CActor)ent).SignalGameplayEventParamInt( 'RidingManagerMountHorse', MT_instant | MT_fromScript );
		}
			
		((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		
	}
}




