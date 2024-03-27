from os import path
from typing import List
from datetime import datetime
from beancount.ingest import importer
from beancount.core import data, amount
from beancount.core.number import D

from pypdf import PdfReader
import re

number_re = re.compile(r"-?\d([\d\s]*,\d\d)")
num_re = re.compile(r"\d+")


class Table:
    headers: List[str]
    items: List[dict]
    last: str
    ignore: bool

    def __init__(self, last="(EUR)", ignore=True):
        self.headers = []
        self.items = []
        self.last = last
        self.ignore = ignore

    def parse(self, lines: List[str]) -> List[str]:
        phase = 0
        consumed = 0
        cur = []
        items = []
        parsing = ""
        for line in lines:
            consumed += 1
            if phase == 0:
                if line != self.last:
                    if line.endswith(" "):
                        parsing = line
                        continue
                    else:
                        self.headers.append(parsing + line)
                        parsing = ""
                else:
                    if not self.ignore:
                        self.headers.append(line)
                    phase = 1
            elif phase == 1:
                if match := number_re.match(line):
                    n = re.sub(r"[\s]", "", match.string)
                    n = re.sub(r",", ".", n)
                    cur.append(D(n))
                elif num_re.match(line):
                    cur.append(line)
                else:
                    if len(cur) != 0:
                        if cur[0].startswith("Total"):
                            break
                        items.append(cur)
                        cur = []
                    cur.append(line.strip())
        for item in items:
            if len(item) != len(self.headers):
                item = [item[0]] + [None] * (len(self.headers) - len(item)) + item[1:]

            self.items.append(dict(zip(self.headers, item)))

        return lines[consumed - 1 :]


class Importer(importer.ImporterProtocol):
    def __init__(
        self,
        currency,
        account_salary,
        account_meal,
        account_ss,
        account_irs,
        decryption,
    ):
        self.currency = currency
        self.account_salary = account_salary
        self.account_meal = account_meal
        self.account_ss = account_ss
        self.account_irs = account_irs
        self.decryption = decryption

    def identify(self, file):
        return path.basename(file.name).startswith("Recibo") and file.name.endswith(
            ".pdf"
        )

    def file_account(self, _):
        return "Income:Salary:Main"

    def file_name(self, file):
        return f"earnings.{self.file_date(file).strftime('%Y-%m')}.pdf"

    def file_date(self, file):
        base = path.basename(file.name)
        date_part = base.split(" ")[1]
        [mon, year] = date_part.split("_")
        years_table = {
            "Janeiro": 1,
            "Fevereiro": 2,
            "Março": 3,
            "Abril": 4,
            "Maio": 5,
            "Junho": 6,
            "Julho": 7,
            "Agosto": 8,
            "Setembro": 9,
            "Outubro": 10,
            "Novembro": 11,
            "Dezembro": 12,
        }
        real_mon = years_table[mon]

        return datetime(year=int(year), month=real_mon, day=25).date()

    def extract(self, file):
        reader = PdfReader(file.name)
        if reader.is_encrypted:
            reader.decrypt(self.decryption)
        page = reader.pages[0]

        earnings = Table()
        remaining = earnings.parse(page.extract_text().splitlines())

        postings = []
        total = amount.ZERO

        for item in earnings.items:
            acct = None
            match item["Retribuição"]:
                case "Vencimento Base" | "Desconta Vencimento":
                    acct = "Income:Salary:Main"
                case (
                    "Isenção Horário de Trabalho" | "Desconta Isenção Horario Trabalho"
                ):
                    acct = "Income:Salary:Isenção"
                case "Duodecimos Sub Ferias 100%":
                    acct = "Income:Salary:SubFérias"
                case "Duodecimos Sub Natal 100%":
                    acct = "Income:Salary:SubNatal"
                case "Cartão Refeição" | "Desconto Cartão Refeição":
                    acct = "Income:Salary:Meal"
                case _:
                    continue

            notes = None
            if item["Retribuição"].startswith("Descont"):
                notes = {"discounted days": item["Qtd."]}
            postings.append(
                data.Posting(
                    acct,
                    amount.Amount(-item["Valor"], self.currency),
                    None,
                    None,
                    None,
                    notes,
                )
            )

            if acct == "Income:Salary:Meal":
                postings.append(
                    data.Posting(
                        self.account_meal,
                        amount.Amount(item["Valor"], self.currency),
                        None,
                        None,
                        None,
                        None,
                    )
                )
            else:
                total += item["Valor"]

        deductions = Table(last="Valor", ignore=False)
        deductions.parse(remaining)

        for item in deductions.items:
            acct = None
            match item["Dedução"]:
                case "Segurança Social":
                    acct = self.account_ss
                case x if x.startswith("IRS"):
                    acct = self.account_irs
                case _:
                    continue

            postings.append(
                data.Posting(
                    acct,
                    amount.Amount(item["Valor"], self.currency),
                    None,
                    None,
                    None,
                    None,
                )
            )

            total -= item["Valor"]

        postings.append(
            data.Posting(
                self.account_salary,
                amount.Amount(total, self.currency),
                None,
                None,
                None,
                None,
            )
        )

        txn = data.Transaction(
            data.new_metadata(file.name, 0),
            self.file_date(file),
            self.FLAG,
            "CTW",
            "Salary",
            data.EMPTY_SET,
            data.EMPTY_SET,
            postings,
        )

        return [txn]
