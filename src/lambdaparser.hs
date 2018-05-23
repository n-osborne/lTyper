{-# OPTIONS_HADDOCK ignore-exports #-}
{-|
Module : LambdaParser
Copyrigth : Nicolas Osborne, 2018
Licence : MIT

Provide the function pg2ast which turn a program written in Simply Typed Lambda
Calculus into an Abstract Syntax Tree.

A program in Simply Typed Lambda Calculus is divided into two main parts:

* An @Assignations@ part containing assignations instruction of the form:

    @
    let id Exp
    @
    Where @id@ is an identificator and @Exp@ is a simply styped lambda
    expression.

* A @Program@ part containing the actual computation which may contain @id@
  previously defined in the @Assignations@ part.
-}



module LambdaParser
  ( pg2ast ) where


-- new version with assignations



-- | Abstract Syntax Tree type declaration.
--
-- to be completed
data AST = Empty |
           Leaf { len :: Int -- ^ length of the leaf, which is obviously 1
                , lambdatype :: [Char] -- ^ One of the defined type of the
                                -- language
                , name :: [Char] -- ^ Either a value or an id
                } deriving (Show)

-- | Turn a source file into the corresponding AST.
pg2ast :: [Char] -> AST
pg2ast pg = createAST list_tokens_pg_with_subst
  where list_tokens_pg_with_subst = preparePg list_assignations list_tokens_pg
        where list_assignations = parseAssignations selectAssignations pg
              list_tokens_pg = selectProgram pg



-- | Turn a String into the corresponding list of tokens.
--
-- Whitespace is the separator.
file2list :: [Char] -> [[Char]]
file2list [] = []
file2list (c:cs)
  | c == ' ' = file2list cs
  | otherwise = [res] ++ file2list (drop (length res) (c:cs))
    where res = readStr (c:cs)
          readStr [] = []
          readStr (' ':cs) = []
          readStr (c:cs) = c:readStr cs

{-
file2list src
  take 6 src == "lambda" =
  take 5 src == "apply" =
  take 4 src == "Pair" =
  take 3 src == "Fst" =
  take 3 src == "Snd" =
  take 4 src == "True" =
  take 5 src == "False" =
  take 5 src == "Empty" =
  -}

-- | Return the sub-list corresponding to the list of tokens corresponding to
-- the Assignation part of the source file
--
-- Examples:
--
-- >>> selectAssignations ["Assignations", "DON'T", "PANIC!", "Program", "spam","End"]
-- ["DON'T", "PANIC!"]
--
-- >>> selectAssignations ["Assignations", "let", "x", "Int", "Program", "End"]
-- ["let", "x", "Int"]
selectAssignations :: [[Char]] -> [[Char]]
selectAssignations [] = []
selectAssignations (s:ns)
  | s == "Assignations" = selectAssignations ns
  | s == "Program" = []
  | otherwise = s:selectAssignations ns


-- | Return the sub-list corresponding to the list of tokens corresponding to
-- the Program part of the source file
selectProgram :: [[Char]] -> [[Char]]
selectProgram [] = []
selectProgram (s:ns)
  | s == "Program" = ns
  | otherwise = selectProgram ns

-- | Parse the Assignation part of the source file.
--
-- [@Input@]: The list of tokens corresponding to the Assignation part of the
--source file.
--
-- [@Output@]: A list of Product Id x Exp
parseAssignations :: [[Char]] -> [([Char], [[Char]])]
parserAssignations [] = []
parserAssignations (s:ns)
  | s == "let" = (head ns, [exp]):parseAssignations (drop ((length exp) + 1) ns)
  | otherwise = ("Error", [])
  where exp = read (tail ns)
        read ("let":_) = []
        read (s:ns) = s:read ns
 


-- | Substitute the Id in the list of tokens corresponding to the program part
-- of the source file by the corresponding list of tokens.
preparePg :: [([Char], [[Char]])] -> [[Char]] -> [[Char]]



-- | Create the AST corresponding to the given list of tokens.
createAST [[Char]] -> AST






{--

import GHC.Unicode

-- | Abstract Syntax Tree type declaration.
--
-- An Ast is either an empty tree (correspond to an empty program), or a Node
-- with two children which are Abstract Syntax Trees with leaves.
-- Nodes are for lambda application, so they have an arity of two.
-- Leaves are for names.
data Ast = Empty |
           Node { len :: Int -- ^ length of the tree
                , operator :: [Char] -- ^ tag for the operator, either App or Abs
                , left :: Ast -- ^ either a binder or a lambda abstraction
                , rigth :: Ast -- ^ a lambda expression
                } |
           Leaf { len :: Int -- ^ length of the leaf, which is obviously 1
                , name :: [Char] -- ^ name: id:Type
                } deriving (Show)

-- | Turn a program into the corresponding Abstract Syntax Tree.
pg2ast :: [Char] -> Ast
pg2ast pg = createAst (parsePg pg)

-- | Turn a program into the corresponding list of its tokens.
parsePg :: [Char] -> [[Char]]
parsePg [] = []
parsePg (c:cs)
  | c == '/' = "Abs" : parsePg cs
  | c == '(' = "App" : parsePg cs
  | c == ')' = parsePg cs
  | c == '.' = parsePg cs
  | c == ' ' = parsePg cs
  | otherwise = name : parsePg (drop (length name) (c:cs))
  where name = readName (c:cs)


-- | Turn a list of the tokens of a program into the corresponding Abstact
-- Syntax Tree.
createAst :: [[Char]] -> Ast
createAst [] = Empty
createAst (c:cs)
  | c == "Abs" = Node { len=n, operator=c, left=lAst, rigth=rAst }
  | c == "App" = Node { len=n, operator=c, left=lAst, rigth=rAst }
  | otherwise = Leaf { len=1, name=c }
  where lAst = createAst cs
        rAst = createAst (drop (len lAst) cs)
        n = 1 + len lAst + len rAst

-- | Extract the string corresponding of a name from the point of the program we
-- have reached in the parsing.
readName :: [Char] -> [Char]
readName [] = []
readName s
  | length s >= 3 = readId s
  | otherwise = "Error"

-- | Check that the id is lower case.
readId :: [Char] -> [Char]
readId (c:cs)
  | (isLower c) == True = c:readTypeJgt cs
  | otherwise = "Error"

-- | Check there is a colon between id and type.
readTypeJgt :: [Char] -> [Char]
readTypeJgt (c:cs)
  | c == ':' = c:readType cs
  | otherwise = "Error"

-- | Check the type is a known type.
readType :: [Char] -> [Char]
readType s
  | take 4 s == "Bool" = "Bool"
  | take 3 s == "Nat" = "Nat"
  | take 3 s == "Str" = "Str"
  | take 4 s == "Pair" = "Pair"
  | otherwise = "Error"

--}