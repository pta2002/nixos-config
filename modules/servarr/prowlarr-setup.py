#!/usr/bin/env python3

from typing import Any, Dict
import requests
from dataclasses import dataclass
from abc import ABC, abstractmethod
import rich
import sys
import json

from requests.models import HTTPError


@dataclass
class Application:
    name: str
    implementation: str
    config_contract: str
    api_key: str
    base_url: str
    sync_level: str

    def as_dict(self) -> Dict[str, Any]:
        return {
            "name": self.name,
            "configContract": self.config_contract,
            "implementation": self.implementation,
            "syncLevel": self.sync_level,
            "fields": [
                {"name": name, "value": value}
                for name, value in [
                    ("apiKey", self.api_key),
                    ("baseUrl", self.base_url),
                    ("prowlarrUrl", BASE_URL),
                ]
            ],
        }


class UpdateAction(ABC):
    @abstractmethod
    def print(self):
        pass

    @abstractmethod
    def execute(self, session: requests.Session):
        pass


@dataclass
class DeleteApplication(UpdateAction):
    id: int
    name: str

    def execute(self, session: requests.Session):
        r = session.delete(f"{LOCAL_URL}/api/v1/applications/{self.id}")
        r.raise_for_status()

    def print(self):
        rich.print(f"[bold red]DELETE[/] {self.name}")


@dataclass
class AddApplication(UpdateAction):
    application: Application

    def execute(self, session: requests.Session):
        r = session.post(
            f"{LOCAL_URL}/api/v1/applications", json=self.application.as_dict()
        )
        try:
            r.raise_for_status()
        except HTTPError as e:
            print(r.text)
            raise e

    def print(self):
        rich.print(f"[bold green]ADD[/] {self.application.name}")


@dataclass
class Nothing(UpdateAction):
    application: Application

    def print(self):
        rich.print(f"[bold blue]ALREADY OK[/] {self.application.name}")

    def execute(self, session):
        _ = session
        pass


# Apply a config for prowlarr
if __name__ == "__main__":
    json_config = json.load(open(sys.argv[1], "r"))
    LOCAL_URL = "http://localhost:9696"
    BASE_URL = json_config["url"]
    API_KEY = json_config["apiKey"]
    actions = {}

    session = requests.Session()
    session.headers["X-Api-Key"] = API_KEY

    applications = {}
    for key, val in json_config["applications"].items():
        capitalized_name = key.capitalize()
        url = val["url"]
        api_key = val["apiKey"]

        applications[capitalized_name] = Application(
            name=capitalized_name,
            implementation=capitalized_name,
            config_contract=f"{capitalized_name}Settings",
            api_key=api_key,
            base_url=url,
            sync_level="addOnly",
        )

    # get applications
    r = session.get(f"{LOCAL_URL}/api/v1/applications")
    r.raise_for_status()
    for app in r.json():
        if app["name"] in applications:
            actions[app["name"]] = Nothing(applications[app["name"]])
        else:
            actions[app["name"]] = DeleteApplication(app["id"], app["name"])

    for app in applications.keys():
        if app not in actions:
            actions[app] = AddApplication(applications[app])

    for action in actions.values():
        action.print()
        action.execute(session)
