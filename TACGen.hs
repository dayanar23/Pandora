module TACGen 
    ( initTAC
    , initTACState
    , getAssign
    , listTAC
    , emptyTACState
   -- , makeFunL
    , TACMonad (..)
    )
where

import TAC
import Type
import SymbolTable
import Position
import Control.Monad.RWS
import Data.Maybe
import qualified Data.Foldable as FB
import qualified Data.Sequence as DS
import qualified Data.Map.Strict as DMap

type TACMonad = RWS TACReader TAC TACState 

type TACReader = String

data TACState = 
    TACState 
        { tsyt  :: Zipper
        , tsrt  :: Zipper
        , tast  :: AST
        , temp  :: Int
        , label :: Int
        , lreturn ::String
        } 

initTAC :: TAC 
initTAC = DS.empty

initTACState :: State -> TACState
initTACState sta = 
    TACState
        { tsyt  = syt sta
        , tsrt  = srt sta
        , tast  = ast sta 
        , temp  = 0
        , label = 0
        , lreturn = ""
        } 

newLabel :: TACMonad Label 
newLabel = do 
    newl <- liftM succ $ gets label
    modify $ \x -> x { label = newl }
    return $ Label ('L':(show newl))

newTemp :: TACMonad Reference
newTemp = do 
    newt <- liftM succ $ gets temp
    modify $ \x -> x { temp = newt }
    return $ Temp newt

-- NO DEBE LLAMARSE ASI
getAssign :: Instructions -> TACMonad Ins
getAssign ins = case ins of

    AsngL ex@(IdL s e ps) e2 p -> if (isBool e2) 
        then do
            add <- getAddr ex
            trueL   <- newLabel
            falseL  <- newLabel
            nextL   <- newLabel
            jumpingCode e2 trueL falseL
            let assgn  = PutLabel trueL 
            let assgn2 = AssignU (LPoint) add (Constant (ValBool True))
            let assgn3 = Goto (Just nextL)
            let assgn4 = PutLabel falseL 
            let assgn5 = AssignU (LPoint) add (Constant (ValBool False))
            let assgn6 = PutLabel nextL
            tell $ DS.singleton Block 
            tell $ DS.singleton assgn
            tell $ DS.singleton assgn2
            tell $ DS.singleton assgn3
            tell $ DS.singleton Block
            tell $ DS.singleton assgn4
            tell $ DS.singleton assgn5
            tell $ DS.singleton Block
            tell $ DS.singleton assgn6
            return $ assgn6

        else do
            tell $ DS.singleton (Comment ("Line " ++ show (line p)))
            const <- getReference e2
            add <- getAddr ex
            let assgn = AssignU LPoint add const
            tell $ DS.singleton assgn
            return $ assgn

    AsngL ex@(AccsA s e ps) e2 p -> if (isBool e2) 
        then do
            add <- getAddr ex
            trueL   <- newLabel
            falseL  <- newLabel
            nextL   <- newLabel
            jumpingCode e2 trueL falseL
            let assgn  = PutLabel trueL 
            let assgn2 = Assign add (Constant (ValBool True))
            let assgn3 = Goto (Just nextL)
            let assgn4 = PutLabel falseL 
            let assgn5 = Assign add (Constant (ValBool False))
            let assgn6 = PutLabel nextL 
            tell $ DS.singleton Block
            tell $ DS.singleton assgn
            tell $ DS.singleton assgn2
            tell $ DS.singleton assgn3
            tell $ DS.singleton Block
            tell $ DS.singleton assgn4
            tell $ DS.singleton assgn5
            tell $ DS.singleton Block
            tell $ DS.singleton assgn6
            return $ assgn6

        else do 
            tell $ DS.singleton (Comment ("Line " ++ show (line p)))
            const <- getReference e2
            add <- getAddr ex
            let assgn = AssignU LPoint add const
            tell $ DS.singleton assgn
            return $ assgn
    AsngL ex@(AccsS s e ps) e2 p -> if (isBool e2) 
        then do
            add <- getAddr ex
            trueL   <- newLabel
            falseL  <- newLabel
            nextL   <- newLabel
            jumpingCode e2 trueL falseL
            let assgn  = PutLabel trueL 
            let assgn2 = Assign add (Constant (ValBool True))
            let assgn3 = Goto (Just nextL)
            let assgn4 = PutLabel falseL 
            let assgn5 = Assign add (Constant (ValBool False))
            let assgn6 = PutLabel nextL 
            tell $ DS.singleton Block
            tell $ DS.singleton assgn
            tell $ DS.singleton assgn2
            tell $ DS.singleton assgn3
            tell $ DS.singleton Block
            tell $ DS.singleton assgn4
            tell $ DS.singleton assgn5
            tell $ DS.singleton Block
            tell $ DS.singleton assgn6
            return $ assgn6

        else do 
            tell $ DS.singleton (Comment ("Line " ++ show (line p)))
            const <- getReference e2
            add <- getAddr ex
            let assgn = AssignU LPoint add const
            tell $ DS.singleton assgn
            return $ assgn

    AsngL ex@(AccsP e i po) e2 p -> if (isBool e2)
        then do
            trueL   <- newLabel
            falseL  <- newLabel
            jumpingCode e2 trueL falseL
        else do
            tell $ DS.singleton (Comment ("Line " ++ show (line p)))
            return $ (Comment ("Line " ++ show (line p)))

    IfL ex ins p -> do
        trueL   <- newLabel
        falseL   <- newLabel
        tell $ DS.singleton (Comment ("Line " ++ show (line p)))
        jumpingCode ex trueL falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel trueL)
        mapM_ getAssign (reverse ins)
        let put = PutLabel falseL
        tell $ DS.singleton Block
        tell $ DS.singleton put
        return $ put

    IfteL ex insT insF p -> do
        trueL <- newLabel
        falseL <- newLabel
        tell $ DS.singleton (Comment ("Line " ++ show (line p)))
        jumpingCode ex trueL falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel trueL)
        mapM_ getAssign (reverse insT)
        let put = PutLabel falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel falseL)
        mapM_ getAssign insF
        return $ put

    WhileL ex ins p -> do
        auxL <- newLabel
        trueL <- newLabel
        falseL <- newLabel
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel auxL)
        jumpingCode ex trueL falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel trueL)
        mapM_ getAssign (reverse ins)
        tell $ DS.singleton (Goto (Just auxL))
        let put = PutLabel falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel falseL)
        return $ put

    RepeatL ins ex p -> do
        trueL <- newLabel
        falseL <- newLabel
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel trueL)
        mapM_ getAssign (reverse ins)
        jumpingCode ex trueL falseL
        let put = PutLabel falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel falseL)
        return $ put

    ForL ex1 ex2 ex3 ex4 ins p -> do
        auxL <- newLabel
        trueL <- newLabel
        falseL <- newLabel
        temp0 <- getAddr ex1
        temp1 <- getReference ex2
        let assgn = AssignU (LPoint) temp0 temp1
        tell $ DS.singleton assgn
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel auxL)
        let auxE = ExpBin (Lt IntT) ex1 ex3 p
        jumpingCode auxE trueL falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel trueL)
        mapM_ getAssign (reverse ins)
        getAssign (AsngL ex1 ex4 p)
        tell $ DS.singleton (Goto (Just auxL))
        let put = PutLabel falseL
        tell $ DS.singleton Block
        tell $ DS.singleton (PutLabel falseL)
        return $ put

    ReadL ex p -> do
        param <- getReference ex
        rea <- makeRead (typeExp ex) param
        return $ (Comment ("Line " ++ show (line p)))

    -- Creo que hay que crear el tipo del write con los diferentes en la tac mas que 
    -- llamar a la funcion pero no estoy seguro

    WriteL ex p -> do 
        case typeExp ex of
            StringT -> do
                        makeWriteS ex
                        return $ (Comment ("Line " ++ show (line p))) 
            _       -> do
                        param <- getReference ex
                        writ <- makeWrite (typeExp ex) param
                        return $ (Comment ("Line " ++ show (line p)))
        

    ReturnL ex p -> do
        la <- gets lreturn
        temp0 <- getReference ex 
        let assgn = Return (Just temp0) la
        tell $ DS.singleton assgn
        return $ assgn 

    DecFun ex@(IdL s e p) -> do
        st <- get
        put st {lreturn = s}
        let (ast, lt) = astEntry e
        let assgn = PutLabel (Label s)
        tell $ DS.singleton Block
        tell $ DS.singleton assgn
        let tam = getIntFun e
        let assgn1 = Prologue tam
        tell $ DS.singleton assgn1
        mapM_ getAssign (listTAC $ filterI ast)
        let assgn2 = Epilogue tam 
        tell $ DS.singleton (PutLabel (Label (s ++ "_ep")))
        tell $ DS.singleton assgn2
        return assgn2

    Begin i -> do
        let assgn = PutLabel (Label "main")
        tell $ DS.singleton Block
        tell $ DS.singleton assgn
        let assgn1 = Prologue i
        tell $ DS.singleton assgn1
        return assgn1

    End -> do
        let assgn = Exit 
        tell $ DS.singleton assgn
        return assgn

    FCallI ex exs p ->
        case ex of
            (IdL s e pos) -> do
                st <- get
                mapM_ makeParams exs
                temp <- newTemp
                let assgn = CallP s (length exs) -- aqui numero que es
                tell $ DS.singleton assgn
                let tam = getIntFun e
                let assgn2 = CleanUp tam
                tell $ DS.singleton assgn2
                return $ assgn2

            StringL s p -> do
                st <- get
                mapM_ makeParams exs
                temp <- newTemp
                let assgn = CallP s 1 -- aqui numero que es
                tell $ DS.singleton assgn
                let assgn2 = CleanUp (sum $ sizeCal (tsyt st) exs)
                tell $ DS.singleton assgn2
                return $ assgn2

    p -> do
        let assg = (Comment ("Line " ++ show p))
        tell $ DS.singleton assg
        return assg

getReference :: Expression -> TACMonad Reference
getReference exp = case exp of
    BoolL  b p  -> return $ Constant $ ValBool  b
    IntL   i p  -> return $ Constant $ ValInt   i 
    FloatL f p  -> return $ Constant $ ValFloat f
    CharL  c p  -> return $ Constant $ ValChar  c 
    StringL s p -> return $ Constant $ ValString s

    ex@(IdL s e p) -> do
        add <- getAddr ex
        temp <- newTemp
        let assgn = AssignU RPoint temp add
        tell $ DS.singleton assgn
        return $ temp

    ex@(AccsA s e p) -> do 
        add <- getAddr ex
        temp <- newTemp
        let assgn = AssignU RPoint temp add
        tell $ DS.singleton assgn
        return $ temp

    ex@(AccsS s e p) -> do 
        add <- getAddr ex
        temp <- newTemp
        let assgn = AssignU RPoint temp add
        tell $ DS.singleton assgn
        return $ temp

    ex@(AccsP e i p) -> do 
        temp <- newTemp
        return $ temp


    ExpBin op e1 e2 p -> do 
        const1 <- getReference e1
        const2 <- getReference e2
        nt <- newTemp
        let assgn = AssignB (makeBOpp op) nt const1 const2
        tell $ DS.singleton assgn
        return $ nt

    ExpUna op e1 p -> do
        const1 <- getReference e1
        nt <- newTemp
        let assgn = AssignU (makeUOpp op) nt const1
        tell $ DS.singleton assgn
        return $ nt

    FCall ex exs p ->
        case ex of
            (IdL s e pos) -> do
                st <- get
                mapM_ makeParams exs
                temp <- newTemp
                let assgn = Call temp s (length exs) -- aqui numero que es
                tell $ DS.singleton assgn
                let assgn2 = CleanUp (sum $ sizeCal (tsyt st) exs)
                tell $ DS.singleton assgn2
                return $ temp

            StringL s p -> do
                st <- get
                mapM_ makeParams exs
                temp <- newTemp
                let assgn = Call temp s 1 -- aqui numero que es
                tell $ DS.singleton assgn
                let assgn2 = CleanUp (sum $ sizeCal (tsyt st) exs)
                tell $ DS.singleton assgn2
                return $ temp

emptyZipper :: Zipper
emptyZipper = focus $ emptyST emptyScope

makeBOpp op = case op of
    Plus t  -> if t == IntT then AddI else AddF 
    Minus t -> if t == IntT then SubI else SubF
    Mul t   -> if t == IntT then MulI else MulF
    Slash t -> if t == IntT then DivI else DivF
    Div     -> DivI
    Mod t   -> ModT
    Power t -> PowT
    And     -> AndT
    Or      -> OrT

makeUOpp op = case op of
    Not -> NotT
    Minus t -> if t == IntT then NegI else NegF

getAddr :: Expression -> TACMonad Reference
getAddr e = case e of 
    IdL s (Entry t _ sz o) _ -> 
        do  temp <- newTemp 
            let assgn = AssignB AddI temp FP (Constant (ValInt o))
            tell $ DS.singleton assgn
            return $ temp
    AccsA (IdL st (Entry t _ s o) _) es _ -> 
        do  arrayAcc <- auxArray st t (reverse es)
            temp1 <- newTemp
            temp2 <- newTemp
            let assgn1 = AssignB AddI temp1 FP (Constant (ValInt o)) -- No se si es un Addi o RArray
            let assgn2 = AssignB AddI temp2 temp1 arrayAcc
            tell $ DS.singleton assgn1
            tell $ DS.singleton assgn2
            return $ temp2
    AccsS ex@(IdL st (Entry _ _ s o) _) es _ -> 
        do aux ex es

    AccsP ex@(IdL st (Entry t _ s o)_ ) i p ->
        do  temp2 <- newTemp
            return $ temp2

aux :: Expression -> [Expression] -> TACMonad Reference
aux (IdL st (Entry _ _ s o) _) es = do
    temp1 <- newTemp
    let assgn = AssignB AddI temp1 FP (Constant(ValInt o))
    let offs = map offsetCal es
    tell $ DS.singleton assgn
    auxStruct temp1 offs

auxStruct :: Reference -> [Int]-> TACMonad Reference
auxStruct r [o] = do 
    temp <- newTemp 
    let assgn = AssignB AddI temp r (Constant (ValInt o))
    tell $ DS.singleton assgn
    return $ temp
auxStruct r (o:os) = do
    temp <- newTemp 
    let assgn = AssignB AddI temp r (Constant (ValInt o))
    tell $ DS.singleton assgn
    auxStruct temp os

auxArray :: String -> Type-> [Expression] -> TACMonad Reference
auxArray s (ArrayT d t) [e] = do
    symt    <- get 
    const1  <- getReference $ e
    temp1   <- newTemp
    let assgn = AssignB MulI temp1 (Constant (ValInt (typeSize' t (tsyt symt)))) const1
    tell $ DS.singleton assgn
    return $ temp1

auxArray s a@(ArrayT d t) l@(e:es) = do
    symt    <- get 
    const1  <- getReference $ e
    let n = getNdimention a
    temp2 <- makeDimArray n 
    temp1 <- newTemp
    let assgn1 = AssignB MulI temp1 const1 temp2
    tell $ DS.singleton assgn1
    auxArray' t es (init n) temp1

auxArray':: Type-> [Expression] -> [Expression] -> Reference -> TACMonad Reference
auxArray' (ArrayT d t) [e] n r = do
    symt    <- get 
    const1  <- getReference $ e
    temp1   <- newTemp
    temp2   <- newTemp
    let assgn2 = AssignB AddI temp1 const1 r
    let assgn = AssignB MulI temp2 (Constant (ValInt (typeSize' t (tsyt symt)))) temp1
    tell $ DS.singleton assgn2
    tell $ DS.singleton assgn
    return $ temp2

auxArray' a@(ArrayT d t)(e:es) n r = do
    symt    <- get 
    const1  <- getReference $ e
    temp2   <- makeDimArray n
    temp1   <- newTemp
    temp3   <- newTemp
    let assgn1 = AssignB MulI temp1 const1 temp2
    let assgn2 = AssignB AddI temp3 temp1 r
    tell $ DS.singleton assgn1
    tell $ DS.singleton assgn2
    auxArray' t es (init n) temp3

makeDimArray :: [Expression] -> TACMonad Reference
makeDimArray [n1, n2]  = do
    cons <- getReference n1
    return $ cons

makeDimArray (n1:n2:ns) = do
    const1  <- getReference n1
    const2  <- getReference n2
    temp2   <- newTemp
    let assgn = AssignB MulI temp2 const1 const2
    tell $ DS.singleton assgn
    makeDimArray' ns temp2

makeDimArray' :: [Expression] -> Reference -> TACMonad Reference
makeDimArray' [n1] r   = do
    return $ r

makeDimArray' (n1:ns) r = do
    temp1   <- getReference n1
    temp2   <- newTemp
    let assgn = AssignB MulI temp2 temp1 r
    tell $ DS.singleton assgn
    makeDimArray' ns temp2

typeSize' (FuncT t ts i ast) z    = typeSize' t z
typeSize' (ProcT t ts i ast) z    = typeSize' t z
typeSize' (TypeT s) z           = sm
    where (Entry t p sm o)      = fst $ fromJust $ lookupS s z
typeSize' (StructT m) z         = structSize m z
typeSize' (UnionT m) z          = unionSize m z 
typeSize' (ArrayT d t) z        = typeSize' t z
typeSize' t z                   = typeSize t 

structSize m z                          = DMap.foldl (structS z) 0 m
structS z n (Entry (TypeT s) p sz off)  = n + sm
    where (Entry t p sm o)              = fst $ fromJust $ lookupS s z
structS z n (Entry t p sz off)          = n + typeSize' t z

unionSize m z                           = DMap.foldl (unionS z) 0 m
unionS z n (Entry (TypeT s) p sz off)   = if n > sm then n else sm
    where (Entry t p sm o)              = fst $ fromJust $ lookupS s z
unionS z n (Entry t p sz off)           = if n > typeSize' t z then n else typeSize' t z  

isBool :: Expression -> Bool
isBool (BoolL b p)                     = True
isBool (ExpUna Not _ p)              = True
isBool (IdL s (Entry t p sz o) po)   = (t == BoolT)
isBool (AccsA e es p)               = isBool e
isBool (AccsS e es p)               = isBool (head $ reverse es)
isBool (ExpBin op _ _ p )             = case op of
                Gt _        -> True
                Lt _        -> True 
                GEt _       -> True
                LEt _       -> True
                Equal _     -> True
                Inequal _   -> True
                And         -> True
                Or          -> True
                _           -> False
isBool _                            = False


jumpingCode :: Expression -> Label -> Label -> TACMonad Ins
jumpingCode e tl fl = case e of 
    BoolL t p-> do
        tell $ DS.singleton (Comment ("Line " ++ show (line p))) 
        let goto = Goto (Just (if t then tl else fl))
        tell $ DS.singleton goto 
        return goto

    ExpBin op e1 e2 p-> case op of
        And  -> do
            rLabel <- newLabel
            jumpingCode e1 rLabel fl
            tell $ DS.singleton Block
            tell $ DS.singleton (PutLabel rLabel)
            jumpingCode e2 tl fl 
        Or   -> do
            rLabel <- newLabel
            jumpingCode e1 tl rLabel
            tell $ DS.singleton Block
            tell $ DS.singleton (PutLabel rLabel)
            jumpingCode e2 tl fl

        _    -> do
            tell $ DS.singleton (Comment ("Line " ++ show (line p)))
            expl <- getReference e1
            expr <- getReference e2
            let ifgoto  = IfGoto (toRel op) expl expr (Just tl)
            tell $ DS.singleton ifgoto
            tell $ DS.singleton Block
            let goto    = Goto (Just fl)
            tell $ DS.singleton goto
            return goto

    ExpUna op e1 p-> do 
        jumpingCode e1 fl tl
        return $ (Comment ("Line " ++ show (line p)))

    ex@(IdL s e p) -> do
        temp <- getReference ex
        let ifgoto = IfTrue temp (Just tl)
        tell $ DS.singleton ifgoto
        tell $ DS.singleton Block
        tell $ DS.singleton (Goto (Just fl))
        return ifgoto

toRel:: Operator -> Relation
toRel o = case o of 
    Gt _    -> GtT
    Lt _    -> LtT
    GEt _   -> Ge
    LEt _   -> Le
    Equal _ -> Eq
    Inequal _ -> Ne

offsetCal :: Expression -> Int 
offsetCal (IdL _ (Entry _ _ _ o) _) = o 

sizeCal :: Zipper -> [Expression] -> [Int]
sizeCal z []    = [0]
sizeCal z (ex:exs) = (typeSize' (typeExp ex) z):(sizeCal z exs)

sizeCal' :: Zipper -> [(Type,Bool)] -> [Int]
sizeCal' z []    = [0]
sizeCal' z (ex:exs) = (typeSize' (fst ex) z):(sizeCal' z exs)

makeParams :: Expression -> TACMonad Reference
makeParams e = do
    temp <- getReference e
    let p = Param temp
    tell $ DS.singleton p
    return $ temp

makeParams' :: Expression -> Bool -> TACMonad Reference
makeParams' e b = case b of
    True -> do
            temp <- getReference e
            let p = Param temp
            tell $ DS.singleton p
            return $ temp
    _    -> do
            temp <- getReference e
            let p = Param temp
            tell $ DS.singleton p
            return $ temp

astEntry :: Entry -> (AST, [(Type,Bool)])
astEntry e@(Entry t@(FuncT _ l _ ast) _ _ _ ) = (ast, l)
astEntry e@(Entry t@(ProcT _ l _ ast) _ _ _ ) = (ast, l)

getNdimention :: Type -> [Expression]
getNdimention (ArrayT d t@(ArrayT d' t'))   = (IntL d (Position (0,0))):(getNdimention t)
getNdimention (ArrayT d ty)                 = [(IntL d (Position (0,0)))] 


-- Falta las CFunc
makeWrite :: Type -> Reference -> TACMonad Ins
makeWrite t r = 
    case t of 
        IntT -> do
            let assgn = WriteI r -- aqui numero ue es
            tell $ DS.singleton assgn
            return $ assgn
        FloatT -> do
            let assgn = WriteF r -- aqui numero ue es
            tell $ DS.singleton assgn
            return $ assgn
        BoolT -> do 
            let assgn = WriteB r -- aqui numero ue es
            tell $ DS.singleton assgn
            return $ assgn
        CharT -> do
            let assgn = WriteC r -- aqui numero ue es
            tell $ DS.singleton assgn
            return $ assgn
        (FuncT t _ _ _) -> do 
            makeWrite t r

makeWriteS:: Expression -> TACMonad Ins
makeWriteS (StringL s p) = do
    let assgn = WriteS s 
    tell $ DS.singleton assgn
    let assgn2 = CleanUp 0
    tell $ DS.singleton assgn2
    return $ assgn


getIntFun :: Entry -> Int
getIntFun (Entry (ProcT _ _ i _) _ _ _) = i
getIntFun (Entry (FuncT _ _ i _) _ _ _) = i
--falta el reference

makeRead :: Type -> Reference -> TACMonad Ins
makeRead t r = 
    case t of 
        IntT -> do
            let assgn = ReadI r -- aqui numero ue es
            tell $ DS.singleton assgn
            return $ assgn

        (FuncT t _ _ _) -> do 
            makeRead t r        

emptyTACState = TACState emptyZipper emptyZipper (AST []) 0 0

listTAC :: AST -> [Instructions]
listTAC (AST ins) = ins