from pydantic import BaseModel

class InputData(BaseModel):
    transactionId: str = None
    docType: str = None
    issuingCountry: str = None
    lastName: str = None
    firstNames: str = None
    docNumber: str = None
    nationality: str = None
    birthDate: str = None
    gender: str = None
    expirationDate: str = None
    personalNumber: str = None

