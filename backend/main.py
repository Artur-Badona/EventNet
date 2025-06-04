from fastapi import FastAPI, Depends, HTTPException, Query, File, UploadFile, status
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
import database, models, schemas, crud, auth
from models import Inscricao, Evento, Usuario
from schemas import InscricaoCreate
from typing import List, Optional
from datetime import datetime
import os
import uuid

app = FastAPI()
UPLOAD_DIR = "uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)

models.Base.metadata.create_all(bind=database.engine)

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/registrar", response_model=schemas.UsuarioOut)
def registrar(usuario: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    return crud.criar_usuario(db, usuario)


@app.post("/upload-image/")
async def upload_image(file: UploadFile = File(...)):
    # Gera um nome único
    ext = file.filename.split('.')[-1]
    file_name = f"{uuid.uuid4()}.{ext}"
    file_path = os.path.join(UPLOAD_DIR, file_name)

    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)

    return {"filename": file_name, "url": f"/images/{file_name}"}

@app.post("/evento", response_model=schemas.EventoOut)
def postar_evento_com_token(
    evento: schemas.EventoCreate,
    db: Session = Depends(get_db),
    usuario: dict = Depends(auth.verificar_token)
):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()

    db_evento = models.Evento(
        titulo = evento.titulo,
        descricao = evento.descricao,
        data_inicio_inscricao = evento.data_inicio_inscricao,
        data_fim_inscricao = evento.data_fim_inscricao,
        data_evento = evento.data_evento,
        imagem = evento.imagem,
        maximo_inscricoes = evento.maximo_inscricoes,
        localizacao = evento.localizacao,
        id_categoria = evento.id_categoria,
        id_usuario = db_usuario.id
    )

    db.add(db_evento)
    db.commit()

    return db_evento

    return db_evento
@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.autenticar_usuario(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=400, detail="Credenciais inválidas")
    access_token = auth.criar_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/inscricoes", status_code=status.HTTP_201_CREATED)
def inscrever_usuario(
    inscricao: InscricaoCreate,
    usuario: dict = Depends(auth.verificar_token),
    db: Session = Depends(get_db)
):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    evento = db.query(Evento).filter(Evento.id == inscricao.id_evento).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento não encontrado")

    ja_inscrito = db.query(Inscricao).filter_by(
        id_evento=inscricao.id_evento,
        id_usuario=db_usuario.id
    ).first()
    if ja_inscrito:
        raise HTTPException(status_code=400, detail="Usuário já está inscrito neste evento")

    total_inscritos = db.query(Inscricao).filter_by(id_evento=inscricao.id_evento).count()
    if total_inscritos >= evento.maximo_inscricoes:
        raise HTTPException(status_code=400, detail="Limite de inscrições atingido")

    nova_inscricao = Inscricao(
        id_evento=inscricao.id_evento,
        id_usuario=db_usuario.id
    )
    db.add(nova_inscricao)
    db.commit()

    return {"mensagem": "Inscrição realizada com sucesso"}


@app.delete("/inscricao/evento/{id_evento}")
def sair_do_evento(id_evento: int, usuario: dict = Depends(auth.verificar_token), db: Session = Depends(get_db)):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    inscricao = db.query(Inscricao).filter(
        Inscricao.id_usuario == db_usuario.id,
        Inscricao.id_evento == id_evento
    ).first()

    if not inscricao:
        raise HTTPException(status_code=404, detail="Inscrição não encontrada")

    db.delete(inscricao)
    db.commit()
    return {"detail": "Inscrição removida com sucesso"}

@app.get("/eventos", response_model=List[schemas.EventoOut])
def listar_eventos(
    id_categoria: Optional[int] = Query(None),
    localizacao: Optional[str] = Query(None),
    data_evento: Optional[datetime] = Query(None),
    db: Session = Depends(get_db)
):
    query = db.query(Evento)

    if id_categoria is not None:
        query = query.filter(Evento.id_categoria == id_categoria)

    if localizacao is not None:
        query = query.filter(Evento.localizacao.ilike(f"%{localizacao}%"))

    if data_evento is not None:
        query = query.filter(Evento.data_evento >= data_evento)

    eventos = query.all()
    return eventos


@app.get("/eventos/inscrito", response_model=List[schemas.EventoOut])
def eventos_inscrito(usuario: dict = Depends(auth.verificar_token), db: Session = Depends(get_db)):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()

    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    inscricoes = db.query(Inscricao).filter(Inscricao.id_usuario == db_usuario.id).all()
    ids_eventos = [i.id_evento for i in inscricoes]

    eventos = db.query(Evento).filter(Evento.id.in_(ids_eventos)).all()
    return eventos

@app.get("/eventos/publicados", response_model=List[schemas.EventoOut])
def eventos_publicados(usuario: dict = Depends(auth.verificar_token), db: Session = Depends(get_db)):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()
    
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    eventos = db.query(Evento).filter(Evento.id_usuario == db_usuario.id).all()
    return eventos


@app.delete("/inscricoes/{id_evento}", status_code=status.HTTP_204_NO_CONTENT)
def cancelar_inscricao(
    id_evento: int,
    usuario: dict = Depends(auth.verificar_token),
    db: Session = Depends(get_db)
):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    inscricao = db.query(Inscricao).filter(
        Inscricao.id_evento == id_evento,
        Inscricao.id_usuario == db_usuario.id
    ).first()

    if not inscricao:
        raise HTTPException(status_code=404, detail="Inscrição não encontrada")

    db.delete(inscricao)
    db.commit()

    return

@app.delete("/evento/{id_evento}", status_code=status.HTTP_204_NO_CONTENT)
def apagar_evento(
    id_evento: int,
    usuario: dict = Depends(auth.verificar_token),
    db: Session = Depends(get_db)
):
    email_usuario = usuario["sub"]
    db_usuario = db.query(Usuario).filter(Usuario.email == email_usuario).first()
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    evento = db.query(Evento).filter(Evento.id == id_evento).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento não encontrado")

    if evento.id_usuario != db_usuario.id:
        raise HTTPException(status_code=403, detail="Não autorizado a apagar este evento")

    db.query(Inscricao).filter(Inscricao.id_evento == id_evento).delete()

    db.delete(evento)
    db.commit()

    return


@app.get("/categorias", response_model=List[schemas.CategoriaOut])
def listar_categorias(db: Session = Depends(get_db)):
    categorias = db.query(models.Categoria).all()
    return categorias

@app.post("/categorias", response_model=schemas.CategoriaOut, status_code=201)
def criar_categoria(categoria: schemas.CategoriaCreate, db: Session = Depends(get_db)):
    nova_categoria = models.Categoria(nome=categoria.nome)
    db.add(nova_categoria)
    db.commit()
    db.refresh(nova_categoria)
    return nova_categoria

app.mount("/images", StaticFiles(directory=UPLOAD_DIR), name="images")