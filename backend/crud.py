from sqlalchemy.orm import Session
import models, schemas, auth



def criar_usuario(db: Session, usuario: schemas.UsuarioCreate):
    hashed = auth.gerar_hash_senha(usuario.senha)
    db_usuario = models.Usuario(nome=usuario.nome, email=usuario.email, senha=hashed)
    db.add(db_usuario)
    db.commit()
    db.refresh(db_usuario)
    return db_usuario

def postar_evento(db: Session, evento: schemas.EventoCreate):
    db_evento = models.Evento(
        titulo = evento.titulo,
        descricao = evento.descricao,
        data_inicio_inscricao = evento.data_inicio_inscricao,
        data_fim_inscricao = evento.data_fim_inscricao,
        data_evento = evento.data_evento,
        imagem = evento.imagem,
        maximo_inscricoes = evento.maximo_inscricoes,
        localizacao = evento.localizacao,
        id_categoria = evento.id_categoria
    )

    db.add(db_evento)
    db.commit()

    return db_evento
    

def autenticar_usuario(db: Session, email: str, senha: str):
    usuario = db.query(models.Usuario).filter(models.Usuario.email == email).first()
    if not usuario or not auth.verificar_senha(senha, usuario.senha):
        return None
    return usuario
