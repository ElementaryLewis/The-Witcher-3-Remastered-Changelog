/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EBTFactComparison
{
    EBFC_Equal,
    EBFC_NotEqual,
    EBFC_Greater,
    EBFC_GreaterOrEqual,
    EBFC_Less,
    EBFC_LessOrEqual
}


class CBTTaskCheckFact extends IBehTreeTask
{
    var factName : string;
    var value : int;
    var comparison : EBTFactComparison;
    var invert : bool;


    function IsAvailable() : bool
    {
        var factValue : int;
        var result : bool;

        factValue = FactsQuerySum( factName );

        result = false;

        switch ( comparison )
        {
            case EBFC_Equal:
                result = factValue == value;
                break;

            case EBFC_NotEqual:
                result = factValue != value;
                break;

            case EBFC_Greater:
                result = factValue > value;
                break;

            case EBFC_GreaterOrEqual:
                result = factValue >= value;
                break;

            case EBFC_Less:
                result = factValue < value;
                break;

            case EBFC_LessOrEqual:
                result = factValue <= value;
                break;
        }

        if ( invert )
        {
            result = !result;
        }

        return result;
    }
}


class CBTTaskCheckFactDef extends IBehTreeConditionalTaskDefinition
{
    default instanceClass = 'CBTTaskCheckFact';

    editable var factName : string;
    editable var value : int;
    editable var comparison : EBTFactComparison;
    editable var invert : bool;

    default value = 1;
    default comparison = EBFC_GreaterOrEqual;
    default invert = false;


    function OnSpawn( taskGen : IBehTreeTask )
    {
        var task : CBTTaskCheckFact;

        task = (CBTTaskCheckFact)taskGen;

        task.factName = factName;
        task.value = value;
        task.comparison = comparison;
        task.invert = invert;
    }
}