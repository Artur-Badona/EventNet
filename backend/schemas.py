from pydantic import BaseModel, EmailStr
from datetime import date, datetime

class UsuarioCreate(BaseModel):
    nome: str
    email: EmailStr
    senha: str


class EventoCreate(BaseModel):
    titulo : str
    descricao : str
    data_inicio_inscricao : date
    data_fim_inscricao : date
    data_evento : datetime
    imagem : str
    maximo_inscricoes : int
    localizacao : str
    id_categoria : int

class EventoOut(BaseModel):
    id: int
    titulo : str
    descricao : str
    data_inicio_inscricao : date
    data_fim_inscricao : date
    data_evento : datetime
    imagem : str
    maximo_inscricoes : int
    localizacao : str
    id_categoria : int
    id_usuario : int

    class Config:
        from_attributes = True

class UsuarioLogin(BaseModel):
    email: EmailStr
    senha: str

class UsuarioOut(BaseModel):
    id: int
    nome: str
    email: EmailStr

    class Config:
        from_attributes = True

class InscricaoCreate(BaseModel):
    id_evento: int

class CategoriaOut(BaseModel):
    id: int
    nome: str

    class Config:
        orm_mode = True

class CategoriaCreate(BaseModel):
    nome: str