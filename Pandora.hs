import Lexer
import Parser
import System.Environment (getArgs)
import SymbolTable
import Type
import TAC -- no es necesario pero necesito el type TAC
import TACGen
import Mips
import MipsGen
import Data.Either (lefts)
import qualified Data.Sequence as DS
--import Instructions
import qualified Data.Foldable as FB
import Control.Monad.RWS 
import Data.Tree
import System.IO

main = do
    args <- getArgs
    str <- if null args
        then getContents
        else readFile (head args)
    case scanner str of
        Right lexs ->
            if null (tail args)
                then if any isTokenError lexs 
                        then mapM_ fPrint (filter isTokenError lexs)
                        else do let (state, bita) = execRWS (parse lexs) "" (State emptyZipper emptyZipper (AST []))
                                print $ defocus $ syt state
                                putStr "Strings Symbol Table:"
                                print $ defocus $ srt state
                                putStr $ drawTree (treeAST (filterDec (ast state)))
                                if not(null (filterBit bita)) then 
                                     do putStr "\nErrors: \n"
                                        putStr (filterBit bita)
                                else do 
                                    putStr "\n\n"
                                    --let (stateT, biT) = execRWS (makeFunL) "" emptyTACState
                                    let (stateT,bitT) = execRWS (mapM_ getAssign (listTAC $ filterI (ast state))) "" (initTACState state)
                                    putStr (unlines $ map show (FB.toList bitT))
                                    let (stateM,bitM) = execRWS (mapM_ buildMips (TPreamble :(FB.toList bitT))) "" (initMIPSState state)
                                    putStr (unlines $ map show (FB.toList bitM))
                                    writeFile "mipsPan.asm" (unlines $ map show (FB.toList bitM))

                            --print $ drop 2 (show (parse lexs) ++ "Accepted") 
                else case head (tail args) of
                    "-l" -> if any isTokenError lexs 
                                then mapM_ fPrint (filter isTokenError lexs)
                                else mapM_ fPrint lexs
                    "-p" -> if any isTokenError lexs 
                                then mapM_ fPrint (filter isTokenError lexs)
                                else do let (state, bita) = execRWS (parse lexs) "" (State emptyZipper emptyZipper (AST []))
                                        print $ defocus $ syt state
                                        print $ defocus $ srt state
                                        putStr (filterBit bita)
                                    --print $ drop 2 (show (parse lexs) ++ "Accepted") 
                    _    -> print help
        Left error -> print error

help :: String
help = "Los flags permitidos por ahora son -l (lexer) y -p (parser)"

emptyZipper :: Zipper
emptyZipper = focus $ emptyST emptyScope

filterBit :: DS.Seq(Binnacle) -> String
filterBit bs = unlines (lefts (FB.toList bs))

--filterBitTAC :: DS.Seq(TAC) -> String
--filterBitTAC ts = unlines $ FB.toList ts
--    case scanner str of
        --Right lexs -> mapM_ fPrint lexs
--        Right lexs -> print (parse lexs)   
        --Left error -> print error
