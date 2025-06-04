from sqlalchemy import Column, Integer, String, ForeignKey, Date, DateTime
from sqlalchemy.orm import relationship
from database import Base

class Usuario(Base):
    __tablename__ = "usuarios"
    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String)
    email = Column(String, unique=True, index=True)
    senha = Column(String)

    eventos_inscritos = relationship("Inscricao", back_populates="usuario")
    eventos = relationship("Evento", back_populates="usuario")

class Evento(Base):
    __tablename__ = "eventos"
    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String)
    descricao = Column(String)
    data_inicio_inscricao = Column(Date)
    data_fim_inscricao = Column(Date)
    data_evento = Column(DateTime)
    imagem = Column(String)
    maximo_inscricoes = Column(Integer)
    localizacao = Column(String)
    id_categoria = Column(Integer, ForeignKey("categorias.id"))
    id_usuario = Column(Integer, ForeignKey("usuarios.id"))

    categoria = relationship("Categoria", back_populates="eventos")
    usuario = relationship("Usuario", back_populates="eventos")

class Categoria(Base):
    __tablename__ = "categorias"
    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String)

    eventos = relationship("Evento", back_populates="categoria")

class Inscricao(Base):
    __tablename__ = "inscricoes"
    id_evento = Column(Integer, ForeignKey("eventos.id"), primary_key=True)
    id_usuario = Column(Integer, ForeignKey("usuarios.id"), primary_key=True)

    usuario = relationship("Usuario", back_populates="eventos_inscritos")
    evento = relationship("Evento")

class Notificacao(Base):
    __tablename__ = "notificacoes"
    id = Column(Integer, primary_key=True, index=True)
    id_evento = Column(Integer, ForeignKey("eventos.id"))
    id_usuario = Column(Integer, ForeignKey("usuarios.id"))
    data_notificar = Column(DateTime)
