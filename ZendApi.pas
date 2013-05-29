{*
 * @file ZendApi.pas
 * @describes PHP/ZEND API
 * @author Régis GAIDOT <rgaidot@swt.fr>
 * @begin 18.04.2002
 * @changeLog 18.04.2002        Régis GAIDOT <rgaidot@swt.fr>   Begin
 * @changeLog 16.07.2002        Régis GAIDOT <rgaidot@swt.fr>
 * @changeLog 16.07.2002                ver: 1.1.1.2 (Add functions)
 * @changeLog 12.08.2002        Régis GAIDOT <rgaidot@swt.fr>
 * @changeLog 12.08.2002                ver: 1.1.1.3 (Add functions)
 * @changeLog 12.08.2002                zend_hash
 *
 * @deprecated ZendGetParameters
 * @deprecated ZendGetParametersEx
 *
 * @describes TSRM, Thread Safe Resource Manager.
 * @describes *_ex() functions form the so-called new "extended" Zend API.
 *      They give a minor speed increase over the old API, but as a tradeoff
 *      are only meant for providing read-only access.
 *
 *
 *}
unit ZendApi;

interface

uses
 Types;

const
  {$IFDEF LINUX}
  ZendLib = 'libphp4.so';
  {$ELSE}
  ZendLib = 'php4ts.dll';
  {$ENDIF}

const
  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes Zend Variable Type Constants
   * @since 1.1.1.1
   * @access public
   * @var IS_NULL Denotes a NULL (empty) value.
   * @var IS_LONG A long (integer) value.
   * @var IS_DOUBLE A double (floating point) value.
   * @var IS_STRING A string.
   * @var IS_ARRAY Denotes an array.
   * @var IS_OBJECT An object.
   * @var IS_BOOL A Boolean value.
   * @var IS_RESOURCE A resource
   * @var IS_CONSTANT A constant (defined) value.
   * @var IS_CONSTANT_ARRAY  A constant array (defined) value.
   * @see zend.h
   *}
  IS_NULL		= 0;
  IS_LONG		= 1;
  IS_DOUBLE	        = 2;
  IS_STRING	        = 3;
  IS_ARRAY	        = 4;
  IS_OBJECT	        = 5;
  IS_BOOL		= 6;
  IS_RESOURCE	        = 7;
  IS_CONSTANT	        = 8;
  IS_CONSTANT_ARRAY	= 9;

const
  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes Zend Variable Type Constants.
   * @since 1.1.1.1
   * @access public
   * @var E_ERROR Signals an error and terminates execution of the script immediately.
   * @var E_WARNING Signals a generic warning.
   * @var E_PARSE Signals a parser error.
   * @var E_NOTICE Signals a notice.
   * @var E_CORE_ERROR Internal error by the core; shouldn't be used by user-written modules.
   * @var E_CORE_WARNING
   * @var E_COMPILE_ERROR Internal error by the compiler.
   * @var E_COMPILE_WARNING
   * @var E_USER_ERROR
   * @var E_USER_WARNING Internal warning by the compiler.
   * @var E_USER_NOTICE
   * @see zend_errors.h
   *}
  E_ERROR               = Longint(1 shl 0);
  E_WARNING             = Longint(1 shl 1);
  E_PARSE               = Longint(1 shl 2);
  E_NOTICE              = Longint(1 shl 3);
  E_CORE_ERROR          = Longint(1 shl 4);
  E_CORE_WARNING        = Longint(1 shl 5);
  E_COMPILE_ERROR       = Longint(1 shl 6);
  E_COMPILE_WARNING     = Longint(1 shl 7);
  E_USER_ERROR          = Longint(1 shl 8);
  E_USER_WARNING        = Longint(1 shl 9);
  E_USER_NOTICE         = Longint(1 shl 10);

const
  SUCCESS = 0;
  FAILURE = -1;
  ZEND_PARSE_PARAMS_QUIET = Longint(1 shl 1);

type
  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes
   * @since 1.1.1.1
   * @access public
   * @var ClassEntry
   * @var Properties
   * @see zend.h
   * @see struct _zend_object
   *}
  ZendObject = record
    ClassEntry: Pointer;
    Properties: Pointer;
  end;

  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes zval type definition.
   * @since 1.1.1.1
   * @access public
   * @var lval Use this property if the variable is of the type IS_LONG,
   *    IS_BOOLEAN, or IS_RESOURCE.
   * @var dval Use this property if the variable is of the type IS_DOUBLE.
   * @var str This structure can be used to access variables of the type
   *    IS_STRING. The member len contains the string length; the member val
   *    points to the string itself. Zend uses C strings; thus, the string
   *    length contains a trailing 0x00.
   * @var ht This entry points to the variable's hash table entry
   *    if the variable is an array
   * @var Obj Use this property if the variable is of the type IS_OBJECT.
   * @see zend.h
   * @see union _zvalue_value
   *}
  ZendValue = record
  case byte of
    1: (lval: Longint);
    2: (dval: Double);
    3: (str: record
         val: PChar;
         len: Integer;
        end;);
    4: (ht: Pointer);
    5: (Obj: Pointer);
  end;

  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes zval type definition.
   * @since 1.1.1.1
   * @access public
   * @var Value Union containing this variable's contents.
   * @var Typ Contains this variable's type.
   * @var Is_Ref 0 means that this variable is not a reference;
   *    1 means that this variable is a reference to another variable.
   * @var RefCount The number of references that exist for this variable.
   * @see zend.h
   * @see struct _zvalue_value
   *}
  HZVAL = ^PZVal;
  PZVal = ^ZVal;
  ZVal = record
    Value: ZendValue;
    Typ: Byte;
    Is_Ref: Byte;
    RefCount: SmallInt;
  end;

type
  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes zend function type definition.
   * @since 1.1.1.1
   * @access public
   * @var Fname
   * @var Handler
   * @var FuncArgTypes
   * @see zend.h
   * @see struct _zend_function_entry
   *}
  ZendFunction = record
    Fname: PChar;
    Handler: Pointer;
    FuncArgTypes: array of byte;
  end;

  {* @author Régis GAIDOT <rgaidot@swt.fr>
   * @describes zend module type definition.
   * @since 1.1.1.1
   * @access public
   * @var Size Usually filled with the "STANDARD_MODULE_HEADER",
   * @var ZendApi Usually filled with the "STANDARD_MODULE_HEADER",
   * @var ZendDebug Usually filled with the "STANDARD_MODULE_HEADER",
   * @var Zts Usually filled with the "STANDARD_MODULE_HEADER",
   * @var Name Contains the module name
   * @var Functions Points to the Zend function block
   * @var ModuleStartupFunc This function is called once upon module initialization
   * @var ModuleShutdownFunc This function is called once upon module shutdown
   * @var RequestStartupFunc This function is called once upon every page request
   * @var RequestShutdownFunc  This function is called once after every page request
   * @var InfoFunc phpinfo()
   * @var Version The version of the module.
   * @var GlobalStartupFunc
   * @var GlobalShutdownFuncGlobal
   * @var GlobalsId
   * @var ModuleStarted
   * @var Typ
   * @var Handle
   * @var ModuleNumber
   * @see zend_modules.h
   * @see struct _zend_module_entry
   *}
  ArrayZendFunction = array of ZendFunction;
  PZendModuleEntry = ^ZendModuleEntry;
  ZendModuleEntry = record
    Size: word;
    ZendApi: Integer;
    ZendDebug: Byte;
    Zts: Byte;
    Name: PChar;
    Functions: ArrayZendFunction;
    ModuleStartupFunc: function:integer;
    ModuleShutdownFunc: function:integer;
    RequestStartupFunc: function:integer;
    RequestShutdownFunc: function:integer;
    InfoFunc: procedure;
    Version: PChar;
    GlobalStartupFunc: procedure;
    GlobalShutdownFuncGlobal: procedure;
    GlobalsId: Integer;
    ModuleStarted: Integer;
    Typ: Byte;
    Handle: ^THandle;
    ModuleNumber: Integer;
  end;

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Old way of retrieving arguments (deprecated)
 * @since 1.1.1.1
 * @access public
 * @param integer $ht
 * @param integer $ParamCount
 * @param pchar $TypeSpec
 * @return integer
 * @see zend_api.h
 * @see zend_get_parameters
 *}
function ZendGetParameters(ht: Integer; ParamCount: Integer;
  TypeSpec: PChar):Integer; cdecl; varargs;
  external ZendLib name 'zend_get_parameters';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Old way of retrieving arguments (deprecated)
 * @since 1.1.1.1
 * @access public
 * @param integer $NumArgs
 * @param pointer $TSRMLS_DC
 * @param pchar $TypeSpec
 * @return integer
 * @see zend_api.h
 * @see zend_get_parameters_ex
 *}
function ZendGetParametersEx(NumArgs: Integer; TSRMLS_DC: Pointer;
  TypeSpec: PChar):Integer; cdecl; varargs;
  external ZendLib name 'zend_get_parameters_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Retrieving Arguments
 * @since 1.1.1.1
 * @access public
 * @param integer $NumArgs
 * @param pointer $TSRMLS_DC
 * @param pchar $TypeSpec
 * @return integer
 * @see zend_api.h
 * @see zend_parse_parameters
 *
 * @type_spec:
 * l - long
 * d - double
 * s - string (with possible null bytes) and its length
 * b - boolean
 * r - resource, stored in zval*
 * a - array, stored in zval*
 * o - object (of any class), stored in zval*
 * O - object (of class specified by class entry), stored in zval*
 * z - the actual zval*
 *
 * | - indicates that the remaining parameters are optional.
 *      The storage variables corresponding to these parameters should
 *      be initialized to default values by the extension,
 *      since they will not be touched by the parsing function
 *      if the parameters are not passed.
 * / - the parsing function will call SEPARATE_ZVAL_IF_NOT_REF()
 *      on the parameter it follows, to provide a copy of the parameter,
 *      unless it's a reference.
 * ! - the parameter it follows can be of specified type or NULL
 *      (only applies to a, o, O, r, and z).
 *      If NULL value is passed by the user, the storage pointer
 *      will be set to NULL.
 *}
function ZendParseParameters(NumArgs: Integer; TSRMLS_DC: Pointer;
  TypeSpec: PChar):Integer; cdecl; varargs;
  external ZendLib name 'zend_parse_parameters';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Retrieving Arguments
 * @since 1.1.1.1
 * @access public
 * @param integer $Flags
 * @param integer $NumArgs
 * @param pointer $TSRMLS_DC
 * @param pchar $TypeSpec
 * @return integer
 * @see zend_api.h
 * @see zend_parse_parameters_ex
 *
 * @type_spec:
 * l - long
 * d - double
 * s - string (with possible null bytes) and its length
 * b - boolean
 * r - resource, stored in zval*
 * a - array, stored in zval*
 * o - object (of any class), stored in zval*
 * O - object (of class specified by class entry), stored in zval*
 * z - the actual zval*
 *
 * | - indicates that the remaining parameters are optional.
 *      The storage variables corresponding to these parameters should
 *      be initialized to default values by the extension,
 *      since they will not be touched by the parsing function
 *      if the parameters are not passed.
 * / - the parsing function will call SEPARATE_ZVAL_IF_NOT_REF()
 *      on the parameter it follows, to provide a copy of the parameter,
 *      unless it's a reference.
 * ! - the parameter it follows can be of specified type or NULL
 *      (only applies to a, o, O, r, and z).
 *      If NULL value is passed by the user, the storage pointer
 *      will be set to NULL.
 *}
function ZendParseParametersEx(Flags: Integer; NumArgs: Integer;
  TSRMLS_DC: Pointer; TypeSpec: PChar):Integer; cdecl; varargs;
  external ZendLib name 'zend_parse_parameters_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Dealing with a variable number of arguments/optional parameters
 * @since 1.1.1.2
 * @access public
 * @param integer $ParamCount
 * @param $zval
 * @param pointer $TSRMLS_DC
 * @return integer
 * @see zend_api.h
 * @see zend_get_parameters_array
 *}
function ZendGetParametersArray(ParamCount: Integer; zval: HZVAL;
  TSRMLS_DC: Pointer):Integer; cdecl; varargs;
  external ZendLib name '_zend_get_parameters_array';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Dealing with a variable number of arguments/optional parameters
 * @since 1.1.1.1
 * @access public
 * @param integer $ParamCount
 * @param $zval
 * @param pointer $TSRMLS_DC
 * @return integer
 * @see zend_api.h
 * @see zend_get_parameters_array_ex
 *}
function ZendGetParametersArrayEx(ParamCount: Integer; zval: HZVAL;
  TSRMLS_DC: Pointer):Integer; cdecl; varargs;
  external ZendLib name '_zend_get_parameters_array_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pointer $ht
 * @param pchar $arKey
 * @param integer $nKeyLength
 * @param pointer $pData
 * @param integer $nDataSize
 * @param pointer $pDest
 * @param integer $flag
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_add_or_update
 *}
function ZendHashAddOrUpdate(ht: Pointer; arKey: PChar;
  nKeyLength: integer; pData: HZVAL; nDataSize: integer; pDest: Pointer;
  flag: integer):Integer; cdecl;
  external ZendLib name 'zend_hash_add_or_update';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pointer $TSRMLS_D
 * @see zend_api.h
 * @see zend_wrong_param_count
 *}
procedure ZendWrongParamCount(TSRMLS_D: Pointer); cdecl;
  external ZendLib name 'zend_wrong_param_count';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $typ
 * @param pchar $msg
 * @see zend_api.h
 * @see zend_error
 *}
procedure ZendError(typ: integer; msg: PChar); cdecl;
  external ZendLib name 'zend_error';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pointer $module
 * @return integer
 * @see zend_api.h
 * @see zend_startup_module
 *}
function ZendStartupModule(module: Pointer):Integer; cdecl;
  external ZendLib name 'zend_startup_module';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes To start a new array
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @return integer
 * @see zend_api.h
 * @see _array_init
 *}
function ArrayInit(arg: pzval):Integer; cdecl;
  external ZendLib name '_array_init';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes To start a new object
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @return integer
 * @see zend_api.h
 * @see object_init
 *}
function ObjectInit(arg: pzval):Integer; cdecl;
  external ZendLib name 'object_init';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an element of type long.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param longint $n
 * @return integer
 * @see zend_api.h
 * @see add_assoc_long
 *}
function AddAssocLong(arg: PZVal; key: PChar;
  n: longint):Integer; cdecl;  external ZendLib name 'add_assoc_long';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an element of type long.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param longint $n
 * @return integer
 * @see zend_api.h
 * @see add_assoc_long_ex
 *}
function AddAssocLongEx(arg: PZVal; key: PChar; KeyLen: integer;
  n: longint):Integer; cdecl;  external ZendLib name 'add_assoc_long_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @return integer
 * @see zend_api.h
 * @see add_assoc_null_ex
 *}
function AddAssocNullEx(arg: PZVal; key: PChar; KeyLen: integer):Integer; cdecl;
  external ZendLib name 'add_assoc_null_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a Boolean element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_assoc_bool
 *}
function AddAssocBool(arg: PZVal; key: PChar;
  b: integer):Integer; cdecl;  external ZendLib name 'add_assoc_bool';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a Boolean element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_assoc_bool_ex
 *}
function AddAssocBoolEx(arg: PZVal; key: PChar; KeyLen: integer;
  b: integer):Integer; cdecl;  external ZendLib name 'add_assoc_bool_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a resource to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $r
 * @return integer
 * @see zend_api.h
 * @see add_assoc_resource
 *}
function AddAssocResource(arg: PZVal; key: PChar;
  r: integer):Integer; cdecl;  external ZendLib name 'add_assoc_resource';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a resource to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param integer $r
 * @return integer
 * @see zend_api.h
 * @see add_assoc_resource_ex
 *}
function AddAssocResourceEx(arg: PZVal; key: PChar; KeyLen: integer;
  r: integer):Integer; cdecl;  external ZendLib name 'add_assoc_resource_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a floating-point value.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param double $d
 * @return integer
 * @see zend_api.h
 * @see add_assoc_double_ex
 *}
function AddAssocDouble(arg: PZVal; key: PChar;
  d: double):Integer; cdecl;  external ZendLib name 'add_assoc_double';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a floating-point value.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param double $d
 * @return integer
 * @see zend_api.h
 * @see add_assoc_double_ex
 *}
function AddAssocDoubleEx(arg: PZVal; key: PChar; KeyLen: integer;
  d: double):Integer; cdecl;  external ZendLib name 'add_assoc_double_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_assoc_string_ex
 *}
function AddAssocString(arg: PZVal; key: PChar; str: PChar;
  duplicate: integer):Integer; cdecl;  external ZendLib name 'add_assoc_string';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_assoc_string_ex
 *}
function AddAssocStringEx(arg: PZVal; key: PChar; KeyLen: integer;
  str: PChar; duplicate: integer):Integer; cdecl;  external ZendLib name 'add_assoc_string_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string with the desired length length to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_assoc_string
 *}
function AddAssocStringl(arg: PZVal; key: PChar; str: PChar;
  duplicate: integer):Integer; cdecl;  external ZendLib name 'add_assoc_stringl';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string with the desired length length to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param pchar $str
 * @param integer $length
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_assoc_stringl_ex
 *}
function AddAssocStringlEx(arg: PZVal; key: PChar; KeyLen: integer;
  str: PChar; length: integer; duplicate: integer):Integer; cdecl;  external ZendLib name 'add_assoc_stringl_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $KeyLen
 * @param pzval $value
 * @return integer
 * @see zend_api.h
 * @see add_assoc_zval_ex
 *}
function AddAssocZvalEx(arg: PZVal; key: PChar; KeyLen: integer;
  value: PZVal):Integer; cdecl;  external ZendLib name 'add_assoc_zval_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an unset element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @return integer
 * @see zend_api.h
 * @see add_assoc_unset
 *}
function AddAssocUnset(arg: PZVal; key: PChar):Integer; cdecl;
  external ZendLib name 'add_assoc_unset';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an element of type long.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @param longint $n
 * @return integer
 * @see zend_api.h
 * @see add_index_long
 *}
function AddIndexLong(arg: PZVal; idx: integer; n: longint):Integer; cdecl;
  external ZendLib name 'add_index_long';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an unset element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @return integer
 * @see zend_api.h
 * @see add_index_long
 *}
function AddIndexUnset(arg: PZVal; idx: integer):Integer; cdecl;
  external ZendLib name 'add_index_unset';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @return integer
 * @see zend_api.h
 * @see add_index_null
 *}
function AddIndexNull(arg: PZVal; idx: integer):Integer; cdecl;
  external ZendLib name 'add_index_null';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a Boolean element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_index_bool
 *}
function AddIndexBool(arg: PZVal; idx: integer; b: integer):Integer; cdecl;
  external ZendLib name 'add_index_bool';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a resource to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @param integer $r
 * @return integer
 * @see zend_api.h
 * @see add_index_resource
 *}
function AddIndexResource(arg: PZVal; idx: integer; r: integer):Integer; cdecl;
  external ZendLib name 'add_index_resource';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a floating-point value.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @param double $d
 * @return integer
 * @see zend_api.h
 * @see add_index_double
 *}
function AddIndexDouble(arg: PZVal; idx: integer; d: double):Integer; cdecl;
  external ZendLib name 'add_index_double';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_index_string
 *}
function AddIndexString(arg: PZVal; idx: integer; str: PChar;
  duplicate: integer):Integer; cdecl;  external ZendLib name 'add_index_string';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string with the desired length length to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $idx
 * @param pchar $str
 * @param integer $length
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_index_stringl
 *}
function AddIndexStringl(arg: PZVal; idx: integer; str: PChar; length: integer;
  duplicate: integer):Integer; cdecl;  external ZendLib name 'add_index_stringl';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $index
 * @param zval $value
 * @return integer
 * @see zend_api.h
 * @see add_index_zval
 *}

function AddIndexZVal(arg: PZVal; index: integer; value: PZVal):Integer; cdecl;
  external ZendLib name 'add_index_zval';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an element of type long.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param longint $n
 * @return integer
 * @see zend_api.h
 * @see add_next_index_long
 *}
function AddNextIndexLong(arg: PZVal; n: longint):Integer; cdecl;
  external ZendLib name 'add_next_index_long';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an unset element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @return integer
 * @see zend_api.h
 * @see add_next_index_unset
 *}
function AddNextIndexUnset(arg: PZVal):Integer; cdecl;
  external ZendLib name 'add_next_index_unset';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @return integer
 * @see zend_api.h
 * @see add_next_index_null
 *}
function AddNextIndexNull(arg: PZVal):Integer; cdecl;
  external ZendLib name 'add_next_index_null';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a Boolean element.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_next_index_bool
 *}
function AddNextIndexBool(arg: PZVal; b: integer):Integer; cdecl;
  external ZendLib name 'add_next_index_bool';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a resource to the array.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param integer $r
 * @return integer
 * @see zend_api.h
 * @see add_next_index_resource
 *}
function AddNextIndexResource(arg: PZVal; r: integer):Integer; cdecl;
  external ZendLib name 'add_next_index_resource';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a floating-point value.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param double $d
 * @return integer
 * @see zend_api.h
 * @see add_next_index_double
 *}
function AddNextIndexDouble(arg: PZVal; d: double):Integer; cdecl;
  external ZendLib name 'add_next_index_double';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_next_index_string
 *}
function AddNextIndexString(arg: PZVal; str: PChar;
  duplicate: integer):Integer; cdecl;
  external ZendLib name 'add_next_index_string';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $str
 * @param integer $length
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_next_index_stringl
 *}
function AddNextIndexStringl(arg: PZVal; str: PChar; length: integer;
  duplicate: integer):Integer; cdecl;  external ZendLib name 'add_next_index_stringl';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a long to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param zval $value
 * @return integer
 * @see zend_api.h
 * @see add_next_index_zval
 *}
function AddNextIndexZval(arg: PZVal; value: zval):Integer; cdecl;
  external ZendLib name 'add_next_index_zval';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a long to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param longint $l
 * @return integer
 * @see zend_api.h
 * @see add_property_long
 *}
function AddPropertyLong(arg: PZVal; key: PChar; l: longint):Integer; cdecl;
  external ZendLib name 'add_property_long';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an unset property to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param longint $l
 * @return integer
 * @see zend_api.h
 * @see add_property_long_ex
 *}
function AddPropertyLongEx(arg: PZVal; key: PChar; keylen: integer;
  l: longint):Integer; cdecl;
  external ZendLib name 'add_property_long_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an unset property to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @return integer
 * @see zend_api.h
 * @see add_property_unset
 *}
function AddPropertyUnset(arg: PZVal; key: PChar):Integer; cdecl;
  external ZendLib name 'add_property_unset';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an null property to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @return integer
 * @see zend_api.h
 * @see add_property_null
 *}
function AddPropertyNull(arg: PZVal; key: PChar):Integer; cdecl;
  external ZendLib name 'add_property_null';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds an null property to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @return integer
 * @see zend_api.h
 * @see add_property_null_ex
 *}
function AddPropertyNullEx(arg: PZVal; key: PChar;
  keylen: integer):Integer; cdecl;
  external ZendLib name 'add_property_null_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a Boolean to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_property_bool
 *}
function AddPropertyBool(arg: PZVal; key: PChar; b: integer):Integer; cdecl;
  external ZendLib name 'add_property_bool';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a Boolean to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_property_bool_ex
 *}
function AddPropertyBoolEx(arg: PZVal; key: PChar; keylen: integer;
  b: integer):Integer; cdecl;
  external ZendLib name 'add_property_bool_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a resource to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $b
 * @return integer
 * @see zend_api.h
 * @see add_property_resource
 *}
function AddPropertyResource(arg: PZVal; key: PChar; r: longint):Integer; cdecl;
  external ZendLib name 'add_property_resource';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a resource to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param longint $r
 * @return integer
 * @see zend_api.h
 * @see add_property_resource_ex
 *}
function AddPropertyResourceEx(arg: PZVal; key: PChar; keylen: integer;
  r: longint):Integer; cdecl;
  external ZendLib name 'add_property_resource_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a double to the object..
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param double $d
 * @return integer
 * @see zend_api.h
 * @see add_property_double
 *}
function AddPropertyDouble(arg: PZVal; key: PChar; d: double):Integer; cdecl;
  external ZendLib name 'add_property_double';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a double to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param double $s
 * @return integer
 * @see zend_api.h
 * @see add_property_double_ex
 *}
function AddPropertyDoubleEx(arg: PZVal; key: PChar; keylen: integer;
  d: double):Integer; cdecl;
  external ZendLib name 'add_property_double_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_property_string
 *}
function AddPropertyString(arg: PZVal; key: PChar; str: Pchar;
  duplicate: integer):Integer; cdecl;
  external ZendLib name 'add_property_string';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param pchar $str
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_property_string_ex
 *}
function AddPropertyStringEx(arg: PZVal; key: PChar; keylen: integer;
  str: Pchar; duplicate: integer):Integer; cdecl;
  external ZendLib name 'add_property_string_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string of the specified length to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param pchar $str
 * @param integer $length
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_property_stringl
 *}
function AddPropertyStringl(arg: PZVal; key: PChar; str: Pchar;
  length: integer; duplicate: integer):Integer; cdecl;
  external ZendLib name 'add_property_stringl';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a string of the specified length to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param pchar $str
 * @param integer $length
 * @param integer $duplicate
 * @return integer
 * @see zend_api.h
 * @see add_property_stringl_ex
 *}
function AddPropertyStringlEx(arg: PZVal; key: PChar; keylen: integer; str: Pchar;
  length: integer; duplicate: integer):Integer; cdecl;
  external ZendLib name 'add_property_stringl_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a zval container to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param pzval $value
 * @return integer
 * @see zend_api.h
 * @see add_property_zval
 *}
function AddPropertyZval(arg: PZVal; key: PChar; value: pzval):Integer; cdecl;
  external ZendLib name 'add_property_zval';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a zval container to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param pzval $value
 * @return integer
 * @see zend_api.h
 * @see add_property_zval_ex
 *}
function AddPropertyZvalEx(arg: PZVal; key: PChar; keylen: integer;
  value: pzval):Integer; cdecl;
  external ZendLib name 'add_property_zval_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Adds a zval container to the object.
 * @since 1.1.1.1
 * @access public
 * @param pzval $arg
 * @param pchar $key
 * @param integer $keylen
 * @param pzval $value
 * @return integer
 * @see zend_api.h
 * @see call_user_function_ex
 *}
function CallUserFunctionEx(HashTable: Pointer; ObjectPp: HZval;
  FunctionName: PZVal; RetvalPtrPtr: HZval; ParamCount:integer;
  params: array of HZVal; NoSeparation: integer ):Integer; cdecl;
  external ZendLib name 'call_user_function_ex';


{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Retrieved using the function.
 * @since 1.1.1.1
 * @access public
 * @param pointer $TSRMLS_D
 * @return pchar
 * @see zend_execute.h
 * @see get_active_function_name
 *}
function GetActiveFunctionName(TSRMLS_D: Pointer):PChar; cdecl;
  external ZendLib name 'get_active_function_name';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Retrieve the name of the file.
 * @since 1.1.1.1
 * @access public
 * @param pointer $TSRMLS_D
 * @return pchar
 * @see zend_execute.h
 * @see zend_get_executed_filename
 *}
function ZendGetExecutedFilename(TSRMLS_D: Pointer):PChar; cdecl;
  external ZendLib name 'zend_get_executed_filename';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pointer $TSRMLS_D
 * @return integer
 * @see zend_execute.h
 * @see zend_get_executed_lineno
 *}
function ZendGetExecutedLineNo(TSRMLS_D: Pointer):integer; cdecl;
  external ZendLib name 'zend_get_executed_lineno';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to a Boolean type.
 * @since 1.1.1.1
 * @access public
 * @param pzval $op
 * @see zend_operators.h
 * @see convert_to_boolean
 *}
procedure ConvertToBoolean(op: PZVal); cdecl;
  external ZendLib name 'convert_to_boolean';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to a Boolean type.
 * @since 1.1.1.1
 * @access public
 * @param hzval $op
 * @see zend_operators.h
 * @see convert_to_boolean
 *}
procedure ConvertToBooleanEx(op: HZVal); cdecl;
  external ZendLib name 'convert_to_boolean_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to a long, the default integer type.
 * @since 1.1.1.1
 * @access public
 * @param pzval $op
 * @see zend_operators.h
 * @see convert_to_long
 *}
procedure ConvertToLong(op: PZVal); cdecl;
  external ZendLib name 'convert_to_long';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to a long, the default integer type.
 * @since 1.1.1.1
 * @access public
 * @param hzval $op
 * @see zend_operators.h
 * @see convert_to_long_ex
 *}
procedure ConvertToLongEx(op: HZVal); cdecl;
  external ZendLib name 'convert_to_long_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pzval $op
 * @param integer $base
 * @see zend_operators.h
 * @see convert_to_long_base
 *}
procedure ConvertToLongBase(op: PZVal; base: integer); cdecl;
  external ZendLib name 'convert_to_long_base';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to a double, the default floating-point type.
 * @since 1.1.1.1
 * @access public
 * @param hzval $op
 * @see zend_operators.h
 * @see convert_to_double_ex
 *}
procedure ConvertToDoubleEx(op: HZVal); cdecl;
  external ZendLib name 'convert_to_double_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to a string. Strings remain untouched.
 * @since 1.1.1.1
 * @access public
 * @param hzval $op
 * @see zend_operators.h
 * @see convert_to_string_ex
 *}
procedure ConvertToStringEx(op: HZVal); cdecl;
  external ZendLib name 'convert_to_string_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to an array. Arrays remain untouched.
 * @since 1.1.1.1
 * @access public
 * @param pzval $op
 * @see zend_operators.h
 * @see convert_to_array
 *}
procedure ConvertToArray(op: PZVal; base: integer); cdecl;
  external ZendLib name 'convert_to_array';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to an array. Arrays remain untouched.
 * @since 1.1.1.1
 * @access public
 * @param hzval $op
 * @see zend_operators.h
 * @see convert_to_array_ex
 *}
procedure ConvertToArrayEx(op: HZVal); cdecl;
  external ZendLib name 'convert_to_array_ex';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces the type to become a NULL value, meaning empty.
 * @since 1.1.1.1
 * @access public
 * @param pzval $op
 * @see zend_operators.h
 * @see convert_to_null
 *}
procedure ConvertToNull(op: PZVal); cdecl;
  external ZendLib name 'convert_to_null';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Forces conversion to an object. Objects remain untouched.
 * @since 1.1.1.1
 * @access public
 * @param pzval $op
 * @param integer $base
 * @see zend_operators.h
 * @see convert_to_object
 *}
procedure ConvertToObject(op: PZVal; base: integer); cdecl;
  external ZendLib name 'convert_to_object';
{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param char $c
 * @see zend_highlight.h
 * @see zend_html_putc
 *}
procedure ZendHtmlPutC(c: Char); cdecl;
  external ZendLib name 'zend_html_putc';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pchar $s
 * @param integer $len
 * @see zend_highlight.h
 * @see zend_html_puts
 *}
procedure ZendHtmlPuts(s: PChar; len: Integer); cdecl;
  external ZendLib name 'zend_html_puts';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see info.h
 * @see php_info_print_table_end
 *}
procedure PHPInfoPrintTableEnd; cdecl;
  external ZendLib name 'php_info_print_table_end';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see info.h
 * @see php_info_print_table_start
 *}
procedure PHPInfoPrintTableStart; cdecl;
  external ZendLib name 'php_info_print_table_start';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $NumCols
 * @param pchar $Header
 * @see info.h
 * @see php_info_print_table_colspan_header
 *}
procedure PHPInfoPrintTableColspanHeader(NumCols: Integer; Header: PChar);
  cdecl;
  external ZendLib name 'php_info_print_table_colspan_header';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see info.h
 * @see php_info_print_style
 *}
procedure PHPInfoPrintStyle; cdecl;
  external ZendLib name 'php_info_print_style';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see info.h
 * @see php_print_style
 *}
procedure PHPPrintStyle; cdecl;
  external ZendLib name 'php_print_style';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see info.h
 * @see php_info_print_hr
 *}
procedure PHPInfoPrintHR; cdecl;
  external ZendLib name 'php_info_print_hr';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see info.h
 * @see php_info_print_box_end
 *}
procedure PHPInfoPrintBoxEnd; cdecl;
  external ZendLib name 'php_info_print_box_end';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $bg
 * @see info.h
 * @see php_info_print_box_start
 *}
procedure PHPInfoPrintBoxStart(bg: Integer); cdecl;
  external ZendLib name 'php_info_print_box_start';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $flag
 * @param pointer $TSRMLS_DC
 * @see info.h
 * @see php_print_info
 *}
procedure PHPPrintInfo(flag: Integer; TSRMLS_DC: Pointer); cdecl;
  external ZendLib name 'php_print_info';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $NumCols
 * @see info.h
 * @see php_info_print_table_header
 *}
procedure PHPInfoPrintTableHeader(NumCols: Integer); cdecl;
  varargs;external ZendLib name 'php_info_print_table_header';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $NumCols
 * @see info.h
 * @see php_info_print_table_row
 *}
procedure PHPInfoPrintTableRow(NumCols: Integer); cdecl;
  varargs; external ZendLib name 'php_info_print_table_row';

  {* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pchar $varname
 * @param plongint $result
 * @see php.h
 * @see cfg_get_long
 *}
function CfgGetLong(Varname: PChar; Result: Plongint):integer; cdecl;
  varargs; external ZendLib name 'cfg_get_long';

  {* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param pchar $varname
 * @param pdouble $result
 * @return integer
 * @see php.h
 * @see cfg_get_double
 *}
 function CfgGetDouble(Varname: PChar; Result: Pdouble):integer; cdecl;
  varargs; external ZendLib name 'cfg_get_double';

 {* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $TsRsrcId
 * @param pointer $THREAD_T
 * @see tsrm.h
 * @see ts_resource_ex
 *}
procedure TsResourceEx(TsRsrcId: Integer; THREAD_T: Pointer); cdecl;
  external ZendLib name 'ts_resource_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @param integer $ExpectedThreads
 * @param integer $ExpectedResources
 * @param integer $DebugLevel
 * @param pchar $DebugFilename
 * @see tsrm.h
 * @see tsrm_startup
 *}
procedure TsrmStartup(ExpectedThreads: Integer; ExpectedResources: Integer;
  DebugLevel: Integer; DebugFilename: PChar); cdecl;
  external ZendLib name 'tsrm_startup';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see tsrm.h
 * @see tsrm_shutdown
 *}
procedure TsrmShutdown(); cdecl;
  external ZendLib name 'tsrm_shutdown';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes
 * @since 1.1.1.1
 * @access public
 * @see tsrm.h
 * @see tsrm_shutdown
 *}
procedure efree(ZVal: PZval); cdecl;
  external ZendLib name '_efree';

{* @author Régis GAIDOT <rgaidott@swt.fr>
 * @describes convertion d'un PChar en PChar Zend.
 * @since 1.1.1.2
 * @access public
 * @param Pchar chaine
 *}
function estrdup(str: Pchar): PChar; cdecl;
  external ZendLib name '_estrdup';

{* @author Régis GAIDOT <rgaidott@swt.fr>
 * @describes copie d'une variable Zend de type IS_STRING.
 * @since 1.1.1.2
 * @access public
 * @param PZVal PZValue
 *}
procedure zvaldtor(PZValue: PZVal); cdecl;
  external ZendLib name '_zval_dtor';

{* @author Régis GAIDOT <rgaidott@swt.fr>
 * @describes constructeur de copie d'un pointeur sur une variable Zend.
 * @since 1.1.1.2
 * @access public
 * @param PZVal PZValue
 *}
procedure zvalcopyctor(PZValue: PZVal); cdecl;
  external ZendLib name '_zval_copy_ctor';

{* @author Régis GAIDOT <rgaidott@swt.fr>
 * @describes destructeur d'un pointeur sur une variable Zend.
 * @since 1.1.1.2
 * @access public
 * @param HZVAL PPZval
 *}
procedure zvalptrdtor(PPZval : HZVAL); cdecl;
  external ZendLib name '_zval_ptr_dtor';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Init Zval
 * @since 1.1.1.1
 * @access public
 * @param PZVal $ZVal
 * @param TypZVal $TypZVal
 *}
procedure InitZVal(var ZValue: PZval; TypZVal: integer); cdecl;

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Init Zval
 * @since 1.1.1.1
 * @access public
 * @param PZVal $ZVal
 *}
procedure FreeZVal(var ZValue: PZval); cdecl;

{* @author Régis GAIDOT <rgaidott@swt.fr>
 * @describes Ajout d'une fonction PHP dans le module Zend.
 * @since 1.1.1.2
 * @access public
 * @param ArrayZendFunction zendFunctions
 * @param PChar name
 * @param Pointer handler
 *}
procedure AddZendFunction(var zendFunctions: ArrayZendFunction;
  const name: PChar; const handler: Pointer);

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Hash init
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param integer $nSize
 * @param pointer $pHashFunction
 * @param pointer $pDestructor
 * @param integer $persistent
 * @see zend_hash.h
 * @see zend_hash_init
 *}
function ZendHashInit(ht: pointer; nSize: integer; pHashFunction: pointer;
  pDestructor: pointer; persistent: integer):integer; cdecl;
  external ZendLib name 'zend_hash_init'; 

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Hash init
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @see zend_hash.h
 * @see zend_hash_init
 *}
procedure ZendHashDestroy(ht: pointer); cdecl;
  external ZendLib name 'zend_hash_destroy';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Hash init
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @see zend_hash.h
 * @see zend_hash_init
 *}
procedure ZendHashClean(ht: pointer); cdecl;
  external ZendLib name 'zend_hash_clean';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Hash exists ?
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pchar $arKey
 * @param longint $nKeyLength
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_exists
 *}
function ZendHashExists(ht: pointer; arKey: Pchar;
  nKeyLength: longint):integer; cdecl;
  external ZendLib name 'zend_hash_exists';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Hash index exists ?
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param longint $h
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_index_exists
 *}
function ZendHashIndexExists(ht: pointer; h: longint):integer; cdecl;
  external ZendLib name 'zend_hash_index_exists';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Data retreival (Find)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pchar $arKey
 * @param longint $nKeyLength
 * @param pointer $pData
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_find
 *}
function ZendHashFind(ht: Pointer; arKey: PChar; nKeyLength: longint;
  pData: HZVAL):Integer; cdecl;
  external ZendLib name 'zend_hash_find';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Data retreival (QuickFind)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pchar $arKey
 * @param longint $nKeyLength
 * @param longint $h 
 * @param pointer $pData
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_quick_find
 *}
function ZendHashQuickFind(ht: Pointer; arKey: PChar; nKeyLength: longint;
  h: longint; pData: HZVAL):Integer; cdecl;
  external ZendLib name 'zend_hash_quick_find';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Data retreival (IndexFind)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param longint $h
 * @param pointer $pData
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_index_find
 *}
function ZendHashIndexFind(ht: Pointer; h: longint;
  var pData: HZVAL):Integer; cdecl;
  external ZendLib name 'zend_hash_index_find';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Move Forward)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pointer $pos
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_move_forward_ex
 *}
function ZendHashMoveForwardEx(ht: pointer;
  pos: pointer):Integer; cdecl;
  external ZendLib name 'zend_hash_move_forward_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Move Forward)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pointer $pos
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_move_forward_ex
 *}
function ZendHashMoveBackwardsEx(ht: pointer;
  pos: pointer):Integer; cdecl;
  external ZendLib name 'zend_hash_move_backwards_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Get Current Key)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pchar   $strindex
 * @param longint $strlength
 * @param longint $numindex
 * @param pointer $duplicate
 * @param pointer $pos
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_get_current_key_ex
 *}
function ZendHashGetCurrentKeyEx(ht: pointer;
  strindex: pchar; strlength: longint; numindex: longint;
  duplicate: pointer; pos: pointer):Integer; cdecl;
  external ZendLib name 'zend_hash_get_current_key_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Current Key Type)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pointer $pos
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_get_current_key_type_ex
 *}
function ZendHashGetCurrentKeyTypeEx(ht: pointer; pos: pointer):Integer; cdecl;
  external ZendLib name 'zend_hash_get_current_key_type_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Current Key Type)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pointer $pos
 * @return integer
 * @see zend_hash.h
 * @see zend_hash_get_current_data_ex
 *}
function ZendHashGetCurrentDataEx(ht: pointer; pData: HZVAL;
  pos: pointer):Integer; cdecl;
  external ZendLib name 'zend_hash_get_current_data_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Internal pointer reset)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pointer $pos
 * @see zend_hash.h
 * @see zend_hash_internal_pointer_reset_ex
 *}
procedure ZendHashInternalPointerResetEx(ht: pointer;
  pos: pointer); cdecl;
  external ZendLib name 'zend_hash_internal_pointer_reset_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Traversing (Internal pointer end)
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @param pointer $pos
 * @see zend_hash.h
 * @see zend_hash_internal_pointer_end_ex
 *}
procedure ZendHashInternalPointerEndEx(ht: pointer;
  pos: pointer); cdecl;
  external ZendLib name 'zend_hash_internal_pointer_end_ex';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Copying, merging and sorting (Copy)
 * @since 1.1.1.3
 * @access public
 * @param pointer $Target
 * @param pointer $Source
 * @param pointer $pCopyConstructor
 * @param pointer $tmp
 * @param longint $size
 * @see zend_hash.h
 * @see zend_hash_copy
 *}
procedure ZendHashCopy(Target: pointer; Source: pointer;
  pCopyConstructor:pointer; tmp: pointer; size:longint); cdecl;
  external ZendLib name 'zend_hash_copy';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Copying, merging and sorting (Merge)
 * @since 1.1.1.3
 * @access public
 * @param pointer $Target
 * @param pointer $Source
 * @param pointer $pCopyConstructor
 * @param pointer $tmp
 * @param longint $size
 * @param integer $overwrite
 * @see zend_hash.h
 * @see zend_hash_merge
 *}
procedure ZendHashMerge(Target: pointer; Source: pointer;
  pCopyConstructor:pointer; tmp: pointer; size:longint;
  overwrite: integer); cdecl;
  external ZendLib name 'zend_hash_merge';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Num elements
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @see zend_hash.h
 * @see zend_hash_num_elements
 *}
function ZendHashNumElements(ht: pointer):integer; cdecl;
  external ZendLib name 'zend_hash_num_elements';

{* @author Régis GAIDOT <rgaidot@swt.fr>
 * @describes Re-Hash
 * @since 1.1.1.3
 * @access public
 * @param pointer $ht
 * @see zend_hash.h
 * @see zend_hash_rehash
 *}
function ZendHashRehash(ht: pointer):integer; cdecl;
  external ZendLib name 'zend_hash_rehash';

implementation

procedure InitZVal(var zvalue: PZval; TypZVal: integer); cdecl;
begin
  New(zvalue);
  zvalue^.RefCount := 1;
  zvalue^.Is_Ref := 0;
  zvalue^.Typ := TypZVal;
end;

procedure FreeZVal(var ZValue: PZval); cdecl;
begin
  FreeMem(ZValue);
end;

procedure AddZendFunction(var zendFunctions: ArrayZendFunction;
  const name: PChar; const handler: Pointer);
var
  numFct: Integer;
begin
  numFct := Length(zendFunctions);
  SetLength(zendFunctions, numFct+1);
  zendFunctions[numFct].fname := name;
  zendFunctions[numFct].handler := handler;
  zendFunctions[numFct].funcargtypes := nil;
end;

end.
