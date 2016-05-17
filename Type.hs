module Type
	( 
	Type (..)
	, makeBtype
	, makeObj
	) where

import Tokens
import Lexeme

data Type = IntT
		| FloatT 
		| BoolT
		| CharT	
		| PointerT
		| VoidT
		| StructT
		| UnionT
		| StringT
		| FuncT BasicT	
		| ProcT BasicT	
		| ArrayT BasicT
		deriving(Show, Eq)	

makeBtype :: Lexeme t -> Type
makeBtype l = case (token l) of
	TokenIntT 		-> IntT
	TokenFloatT 	-> FloatT
	TokenBoolT 		-> BoolT
	TokenCharT 		-> CharT
	TokenStringT 	-> StringT
	TokenVoid 		-> VoidT
	TokenStruct 	-> StructT
	TokenUnion 		-> UnionT
	TokenNew 		-> PointerT

makeObj :: Lexeme t -> Type -> Type
makeObj l bt = case (token l) of
	TokenArray 		-> ArrayT bt
	TokenProc		-> ProcT bt
	TokenFunc		-> FuncT bt
{-   

al agregar una nueva variable/ apuntador:
	- verificar que  no exista en el mismo scope
	- agregar al scope

al declarar una funcion/ procedimiento:
	- verificar que no exista en el mismo scope
	- agregar al scope 
	- nuevo scope para sus parámetros
	- nuevo scope para declaraciones internas
	- cerrar scopes al terminar la declaracion de la funcion

declaración de structs / unions
	- verificar que no exista en el mismo scope
	- agregar al scope 
	- crear scope para sus campos???

declaracion de strings
	- verificar que no exista en el mismo scope
	- agregar al scope de strings

lista de variables:
	- agregarlas a una secuencia y verificar que ninguna esté en el 
	mismo scope
	- agregar las variables al scope
-}